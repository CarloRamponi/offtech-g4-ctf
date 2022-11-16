const socket = new WebSocket(`ws://${window.location.host}/`);

const stats = [];

socket.addEventListener('message', (event) => {
    const data = JSON.parse(event.data);
    stats.push(...data);
    update();
});

let c_1, c_2;

function update() {
    const total_req = stats.length;
    const succ_req = stats.filter((stat) => stat.status === "OK").length;
    const fail_req = stats.filter((stat) => stat.status === "KO").length;
    const avg_time = stats.filter((stat) => stat.status === "OK").reduce((acc, stat) => acc + stat.duration, 0) / succ_req;
    const total_time = stats[stats.length - 1].ts - stats[0].ts + stats[stats.length - 1].duration;


    $('#total_requests').text(total_req);
    $('#successfull_requests').text(succ_req);
    $('#failed_requests').text(fail_req);
    $('#rate_requests').text((fail_req / total_req * 100).toFixed(2) + '%');
    $('#total_time').text(formatTime(avg_time));
    $('#avg_duration').text(formatTime(total_time));

    chart_1(succ_req, fail_req);
    chart_2();
}

function chart_1(succ, fail) {
    if(!c_1) {
        const ctx = document.getElementById('chart_1').getContext('2d');
        c_1 = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Successfull', 'Failed'],
                datasets: [{
                    label: 'Requests',
                    data: [succ, fail],
                    backgroundColor: [
                        'red',
                        'green'
                    ],
                }]
            },
            options: {
                plugins: {
                legend: {
                    display: false
                }
                }
            }
        });
    } else {
        c_1.data.datasets[0].data = [succ, fail];
        c_1.update();
    }
}

function chart_2() {

    const data = stats.map((stat) => ({
        ...stat,
        duration: stat.duration >= 500 ? 0 : stat.duration,
    }));

    if(!c_2) {
        const ctx = document.getElementById('chart_2').getContext('2d');
        c_2 = new Chart(ctx, {
            type: 'line',
            data: {
                labels: stats.map((stat) => stat.ts),
                datasets: [
                    {
                        label: 'Request duration',
                        data: data.map((stat) => stat.duration),
                        pointBackgroundColor: (ctx) => data[ctx.dataIndex]?.status === "OK" ? 'red' : 'green',
                        lineBackgroundColor: 'transparent',
                        borderColor: 'transparent',
                    },
                    {
                        label: 'Threshold',
                        data: new Array(data.length).fill(500),
                        pointBackgroundColor: 'transparent',
                        pointBorderColor: 'transparent',
                        borderColor: 'lightgreen',
                    },
                ]
            },
            options: {
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    xAxes: {
                        ticks: {
                            display: false
                        }
                    }
                }
            }
        });
    } else {
        c_2.data.labels = data.map((stat) => stat.ts);
        c_2.data.datasets[0].data = data.map((stat) => stat.duration);
        c_2.data.datasets[0].pointBackgroundColor = (ctx) => data[ctx.dataIndex]?.status === "OK" ? 'red' : 'green';
        c_2.data.datasets[1].data = new Array(data.length).fill(500);
        c_2.update();
    }
}

function relativeTime(ts) {
    return ts - stats[0].ts;
}

function formatTime(millis) {
    const hours = Math.floor(millis / 3600000);
    const minutes = Math.floor((millis % 3600000) / 60000);
    const seconds = Math.floor(((millis % 360000) % 60000) / 1000);
    const milliseconds = Math.floor(((millis % 360000) % 60000) % 1000);

    let ret = "";

    if (hours > 0) {
        ret += hours + "h ";
    }

    if (minutes > 0) {
        ret += minutes + "m ";
    }

    if (seconds > 0) {
        ret += seconds + "s ";
    }

    if (milliseconds > 0) {
        ret += milliseconds + "ms";
    }

    return ret;
}
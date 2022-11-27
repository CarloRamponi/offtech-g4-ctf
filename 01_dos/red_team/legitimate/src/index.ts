import client from './client';
import './mockServer';
import './statsServer';

const settings = require("../settings.json");

const url = settings.mock_server.enabled ? `http://localhost:${settings.mock_server.port}` : settings.server_url;
client(url);
import client from './client';
import './mockServer';
import './statsServer';

const settings = require("../settings.json");

client(settings.server_url);
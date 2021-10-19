/*
 * This is the Lambda@Edge function used to handle routing to the
 * static Next.js app once it's exported. We need to ensure that we're
 * fetching the correct static file for a given URL.
 *
 * In general we need to add `/index.html` to every URL to get the correct resource
 * e.g. "/person/" -> "/person/index.html"
 *
 * As well as this we need to parse any dynamic paths (currently just
 * the person pages)
 * e.g. "/person/12/timeline" -> "/person/[pid]/timeline/index.html?pid=12"
 *
 */
"use strict";

const querystring = require("querystring");

const isPersonPage = /^\/person\/(\d+)\//;
const hasExtension = /(.+)\.[a-zA-Z0-9]{2,5}$/;

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  let url = request.uri;

  // If it's a person page request
  if (url && url.match(isPersonPage) && !url.match(hasExtension)) {
    const pid = url.match(isPersonPage)[1];
    url = url.replace(`/${pid}/`, "/[pid]/");
    const params = querystring.parse(request.querystring);
    params["pid"] = pid;
    request.querystring = querystring.stringify(params);
  }

  // Add "/index.html" to all pages
  if (url && !url.match(hasExtension)) {
    const slash = url.endsWith("/") ? "" : "/";
    request.uri = url + slash + "index.html";
  }

  return callback(null, request);
};
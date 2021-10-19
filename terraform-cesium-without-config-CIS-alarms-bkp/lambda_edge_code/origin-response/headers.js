"use strict";
exports.handler = (event, context, callback) => {
  //Get contents of response
  const response = event.Records[0].cf.response;
  const headers = response.headers;

  headers["x-frame-options"] = [{ key: "X-Frame-Options", value: "DENY" }];
  headers["strict-transport-security"] = [
    {
      key: "Strict-Transport-Security",
      value: "max-age=63072000; includeSubdomains; preload",
    },
  ];

  //Return modified response
  callback(null, response);
};
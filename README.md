# HTTP Basic Auth Demo (with Sinatra)

This Sinatra app demonstrates gotchas of `realm` in HTTP Basic Auth.

## Install & Run

Requires Ruby >= 1.9.3, and Sinatra.

    $ bundle
    $ rackup
    $ open http://localhost:9292

## The "Gotchas"

1. Even with different `realm` between routes, the browser would send the same credentials (username + password).
- If there are multiple routes that require different credentials in the same host, then the browser would send whatever used in the last authentication.

## Experiments

All the experiments the following preparation steps:

1. Run the Sinatra App with `rackup`
* keep the console open to see the output from logger (request path, wrong credentails when auth failed etc.)
* Open a new "Private Browsing" window each time when preforming a new experiment, in order to prevent the browser from remembering credentials across experiments.
* Open "Network Inspector" in the developer tool of your browser.

### 1) Different `realm`, Same Credentials

Steps:

* Access `/a1`, enter username `abc` and password `a1`.
* Access `/b`.

Expected Results:

* In the console, it should print:

        Auth failed while accessing /b.
        No Credentials

* In the request entry in Network record, there should be no `Authenticate` header.

Actual Results:

* In the console, it prints:

        Auth failed while accessing /b.
        Credentials: ["abc", "a1"]

* In the request entry in Network record, the `Authenticate` header exists, with value `Basic YWJjOmEx`, which, after decoded with base64, equals to `abc:a1`.

### 2) Always Authenticat with the Last-Used Credentials

Steps:

* Access `/a1`, enter username `abc` and password `a1`.
* Access `/a2`, enter username `abc` and password `a2`.
* Access `/a1`.

Expected Results:

* In the console, it should print no error about authentication failure.
* In the request entry in Network record, the `Authenticate` header should exist, with value `Basic YWJjOmEx`, which, after decoded with base64, equals to `abc:a1`.

Actual Results:

* In the console, it prints:

        Auth failed while accessing /a1.
        Credentials: ["abc", "a2"]

* In the request entry in Network record, the `Authenticate` header exists, with value `Basic YWJjOmEy`, which, after decoded with base64, equals to `abc:a2`.

## Conclusion

* In HTTP Basic Auth, `realm` value is not ideal to separate different parts that require different credentials to access.
* The session of HTTP Basic Auth seems to be host-wide. *Explanation Required*
* If there are multiple applications mounted on the same host and authorized with HTTP Basic Auth, the credentials may leak to other applications, since the credentials are not encrypted, only encoded with Base64.

## Explanation Requested

I didn't read the whole [RFC 2617 - HTTP Authentication: Basic and Digest Access Authentication](http://tools.ietf.org/html/rfc2617). If you know more about the behaviors I describe above, please tell me.

## See also

* [RFC 2617 - HTTP Authentication: Basic and Digest Access Authentication](http://tools.ietf.org/html/rfc2617)
* http://stackoverflow.com/a/12701105/664245

## License

Public Domain

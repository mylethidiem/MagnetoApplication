vcl 4.1;

backend default {
    .host = "nginxcontainer_manual_image";
    .port = "80";
}

sub vcl_recv {
    # Never cache cart, checkout, account pages
    if (req.url ~ "/(checkout|cart|customer|account)") {
        return (pass);
    }

    # Never cache POST requests
    if (req.method == "POST") {
        return (pass);
    }
}

sub vcl_backend_response {
    # Cache everything else for 1 hour
    set beresp.ttl = 1h;
}

sub vcl_deliver {
    # Add cache hit/miss header for testing
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

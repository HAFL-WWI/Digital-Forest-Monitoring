# Apache Server Configs v5.0.0 | MIT License
# https://github.com/h5bp/server-configs-apache

# (!) Using `.htaccess` files slows down Apache, therefore, if you have
# access to the main server configuration file (which is usually called
# `httpd.conf`), you should add this logic there.
#
# https://httpd.apache.org/docs/current/howto/htaccess.html

# ######################################################################
# # CROSS-ORIGIN                                                       #
# ######################################################################

# ----------------------------------------------------------------------
# | Cross-origin requests                                              |
# ----------------------------------------------------------------------

# Allow cross-origin requests.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS
# https://enable-cors.org/
# https://www.w3.org/TR/cors/

# (!) Do not use this without understanding the consequences.
#     This will permit access from any other website.
#     Instead of using this file, consider using a specific rule such as
#     allowing access based on (sub)domain:
#
#         Header set Access-Control-Allow-Origin "subdomain.example.com"
#
# (1) When `Access-Control-Allow-Origin` points to a specific rule rather
#     than `*`, then `Vary: Origin` should be sent along with the response.

# <IfModule mod_headers.c>
#     Header set Access-Control-Allow-Origin "*"

#     # (1)
#     # Header append Vary Origin
# </IfModule>

# ----------------------------------------------------------------------
# | Cross-origin images                                                |
# ----------------------------------------------------------------------

# Send the CORS header for images when browsers request it.
#
# https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_enabled_image
# https://blog.chromium.org/2011/07/using-cross-domain-images-in-webgl-and.html

<IfModule mod_setenvif.c>
    <IfModule mod_headers.c>
        <FilesMatch "\.(avifs?|bmp|cur|gif|ico|jpe?g|jxl|a?png|svgz?|webp)$">
            SetEnvIf Origin ":" IS_CORS
            Header set Access-Control-Allow-Origin "*" env=IS_CORS
        </FilesMatch>
    </IfModule>
</IfModule>

# ----------------------------------------------------------------------
# | Cross-origin web fonts                                             |
# ----------------------------------------------------------------------

# Allow cross-origin access to web fonts.
#
# https://developers.google.com/fonts/docs/troubleshooting

<IfModule mod_headers.c>
    <FilesMatch "\.(eot|otf|tt[cf]|woff2?)$">
        Header set Access-Control-Allow-Origin "*"
    </FilesMatch>
</IfModule>

# ----------------------------------------------------------------------
# | Cross-origin resource timing                                       |
# ----------------------------------------------------------------------

# Allow cross-origin access to the timing information for all resources.
#
# If a resource isn't served with a `Timing-Allow-Origin` header that would
# allow its timing information to be shared with the document, some of the
# attributes of the `PerformanceResourceTiming` object will be set to zero.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Timing-Allow-Origin
# https://www.w3.org/TR/resource-timing/
# https://www.stevesouders.com/blog/2014/08/21/resource-timing-practical-tips/

# <IfModule mod_headers.c>
#     Header set Timing-Allow-Origin: "*"
# </IfModule>

# ######################################################################
# # ERRORS                                                             #
# ######################################################################

# ----------------------------------------------------------------------
# | Custom error messages/pages                                        |
# ----------------------------------------------------------------------

# Customize what Apache returns to the client in case of an error.
#
# https://httpd.apache.org/docs/current/mod/core.html#errordocument

# ErrorDocument 404 /404.html

# ----------------------------------------------------------------------
# | Error prevention                                                   |
# ----------------------------------------------------------------------

# Disable the pattern matching based on filenames.
#
# This setting prevents Apache from returning a 404 error as the result of a
# rewrite when the directory with the same name does not exist.
#
# https://httpd.apache.org/docs/current/content-negotiation.html#multiviews

Options -MultiViews

# ######################################################################
# # MEDIA TYPES AND CHARACTER ENCODINGS                                #
# ######################################################################

# ----------------------------------------------------------------------
# | Media types                                                        |
# ----------------------------------------------------------------------

# Serve resources with the proper media types (f.k.a. MIME types).
#
# https://www.iana.org/assignments/media-types/media-types.xhtml
# https://httpd.apache.org/docs/current/mod/mod_mime.html#addtype

<IfModule mod_mime.c>

  # Data interchange

    AddType application/atom+xml                        atom
    AddType application/json                            json map topojson
    AddType application/ld+json                         jsonld
    AddType application/rss+xml                         rss
    AddType application/geo+json                        geojson
    AddType application/rdf+xml                         rdf
    AddType application/xml                             xml


  # JavaScript

    # Servers should use text/javascript for JavaScript resources.
    # https://html.spec.whatwg.org/multipage/scripting.html#scriptingLanguages

    AddType text/javascript                             js mjs


  # Manifest files

    AddType application/manifest+json                   webmanifest
    AddType application/x-web-app-manifest+json         webapp
    AddType text/cache-manifest                         appcache


  # Media files

    AddType audio/mp4                                   f4a f4b m4a
    AddType audio/ogg                                   oga ogg opus
    AddType image/avif                                  avif
    AddType image/avif-sequence                         avifs
    AddType image/bmp                                   bmp
    AddType image/jxl                                   jxl
    AddType image/svg+xml                               svg svgz
    AddType image/webp                                  webp
    AddType video/mp4                                   f4v f4p m4v mp4
    AddType video/ogg                                   ogv
    AddType video/webm                                  webm
    AddType video/x-flv                                 flv

    # Serving `.ico` image files with a different media type prevents
    # Internet Explorer from displaying them as images:
    # https://github.com/h5bp/html5-boilerplate/commit/37b5fec090d00f38de64b591bcddcb205aadf8ee

    AddType image/x-icon                                cur ico


  # WebAssembly

    AddType application/wasm                            wasm


  # Web fonts

    AddType font/woff                                   woff
    AddType font/woff2                                  woff2
    AddType application/vnd.ms-fontobject               eot
    AddType font/ttf                                    ttf
    AddType font/collection                             ttc
    AddType font/otf                                    otf


  # Other

    AddType application/octet-stream                    safariextz
    AddType application/x-bb-appworld                   bbaw
    AddType application/x-chrome-extension              crx
    AddType application/x-opera-extension               oex
    AddType application/x-xpinstall                     xpi
    AddType text/calendar                               ics
    AddType text/markdown                               markdown md
    AddType text/vcard                                  vcard vcf
    AddType text/vnd.rim.location.xloc                  xloc
    AddType text/vtt                                    vtt
    AddType text/x-component                            htc

</IfModule>

# ----------------------------------------------------------------------
# | Character encodings                                                |
# ----------------------------------------------------------------------

# Serve all resources labeled as `text/html` or `text/plain` with the media type
# `charset` parameter set to `UTF-8`.
#
# https://httpd.apache.org/docs/current/mod/core.html#adddefaultcharset

AddDefaultCharset utf-8

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Serve the following file types with the media type `charset` parameter set to
# `UTF-8`.
#
# https://httpd.apache.org/docs/current/mod/mod_mime.html#addcharset

<IfModule mod_mime.c>
    AddCharset utf-8 .appcache \
                     .bbaw \
                     .css \
                     .htc \
                     .ics \
                     .js \
                     .json \
                     .manifest \
                     .map \
                     .markdown \
                     .md \
                     .mjs \
                     .topojson \
                     .vtt \
                     .vcard \
                     .vcf \
                     .webmanifest \
                     .xloc
</IfModule>

# ######################################################################
# # REWRITES                                                           #
# ######################################################################

# ----------------------------------------------------------------------
# | Rewrite engine                                                     |
# ----------------------------------------------------------------------

# (1) Turn on the rewrite engine (this is necessary in order for the
#     `RewriteRule` directives to work).
#
#     https://httpd.apache.org/docs/current/mod/mod_rewrite.html#RewriteEngine
#
# (2) Enable the `FollowSymLinks` option if it isn't already.
#
#     https://httpd.apache.org/docs/current/mod/core.html#options
#
# (3) If your web host doesn't allow the `FollowSymlinks` option, you need to
#     comment it out or remove it, and then uncomment the
#     `Options +SymLinksIfOwnerMatch` line (4), but be aware of the performance
#     impact.
#
#     https://httpd.apache.org/docs/current/misc/perf-tuning.html#symlinks
#
# (4) Some cloud hosting services will require you set `RewriteBase`.
#
#     https://www.rackspace.com/knowledge_center/frequently-asked-question/why-is-modrewrite-not-working-on-my-site
#     https://httpd.apache.org/docs/current/mod/mod_rewrite.html#rewritebase
#
# (5) Depending on how your server is set up, you may also need to use the
#     `RewriteOptions` directive to enable some options for the rewrite engine.
#
#     https://httpd.apache.org/docs/current/mod/mod_rewrite.html#rewriteoptions

<IfModule mod_rewrite.c>

    # (1)
    RewriteEngine On

    # (2)
    Options +FollowSymlinks

    # (3)
    # Options +SymLinksIfOwnerMatch

    # (4)
    # RewriteBase /

    # (5)
    # RewriteOptions <options>

</IfModule>

# ----------------------------------------------------------------------
# | Forcing `https://`                                                 |
# ----------------------------------------------------------------------

# Redirect from the `http://` to the `https://` version of the URL.
#
# https://wiki.apache.org/httpd/RewriteHTTPToHTTPS

# (1) If you're using cPanel AutoSSL or the Let's Encrypt webroot method it
#     will fail to validate the certificate if validation requests are
#     redirected to HTTPS. Turn on the condition(s) you need.
#
#     https://www.iana.org/assignments/well-known-uris/well-known-uris.xhtml
#     https://tools.ietf.org/html/draft-ietf-acme-acme-12

# <IfModule mod_rewrite.c>
#    RewriteEngine On
#    RewriteCond %{HTTPS} !=on
#    # (1)
#    # RewriteCond %{REQUEST_URI} !^/\.well-known/acme-challenge/
#    # RewriteCond %{REQUEST_URI} !^/\.well-known/cpanel-dcv/[\w-]+$
#    # RewriteCond %{REQUEST_URI} !^/\.well-known/pki-validation/[A-F0-9]{32}\.txt(?:\ Comodo\ DCV)?$
#    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
# </IfModule>

# ----------------------------------------------------------------------
# | Suppressing the `www.` at the beginning of URLs                    |
# ----------------------------------------------------------------------

# Rewrite www.example.com → example.com

# The same content should never be available under two different URLs,
# especially not with and without `www.` at the beginning.
# This can cause SEO problems (duplicate content), and therefore, you should
# choose one of the alternatives and redirect the other one.
#
# (!) NEVER USE BOTH WWW-RELATED RULES AT THE SAME TIME!

# (1) Set %{ENV:PROTO} variable, to allow rewrites to redirect with the
#     appropriate schema automatically (http or https).
#
# (2) The rule assumes by default that both HTTP and HTTPS environments are
#     available for redirection.
#     If your SSL certificate could not handle one of the domains used during
#     redirection, you should turn the condition on.
#
#     https://github.com/h5bp/server-configs-apache/issues/52

<IfModule mod_rewrite.c>

    RewriteEngine On

    # (1)
    RewriteCond %{HTTPS} =on
    RewriteRule ^ - [E=PROTO:https]
    RewriteCond %{HTTPS} !=on
    RewriteRule ^ - [E=PROTO:http]

    # (2)
    # RewriteCond %{HTTPS} !=on

    RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
    RewriteRule ^ %{ENV:PROTO}://%1%{REQUEST_URI} [R=301,L]

</IfModule>

# ----------------------------------------------------------------------
# | Forcing the `www.` at the beginning of URLs                        |
# ----------------------------------------------------------------------

# Rewrite example.com → www.example.com

# The same content should never be available under two different URLs,
# especially not with and without `www.` at the beginning.
# This can cause SEO problems (duplicate content), and therefore, you should
# choose one of the alternatives and redirect the other one.
#
# (!) NEVER USE BOTH WWW-RELATED RULES AT THE SAME TIME!

# (1) Set %{ENV:PROTO} variable, to allow rewrites to redirect with the
#     appropriate schema automatically (http or https).
#
# (2) The rule assumes by default that both HTTP and HTTPS environments are
#     available for redirection.
#     If your SSL certificate could not handle one of the domains used during
#     redirection, you should turn the condition on.
#
#     https://github.com/h5bp/server-configs-apache/issues/52

# Be aware that the following might not be a good idea if you use "real"
# subdomains for certain parts of your website.

# <IfModule mod_rewrite.c>

#     RewriteEngine On

#     # (1)
#     RewriteCond %{HTTPS} =on
#     RewriteRule ^ - [E=PROTO:https]
#     RewriteCond %{HTTPS} !=on
#     RewriteRule ^ - [E=PROTO:http]

#     # (2)
#     # RewriteCond %{HTTPS} !=on

#     RewriteCond %{HTTP_HOST} !^www\. [NC]
#     RewriteCond %{SERVER_ADDR} !=127.0.0.1
#     RewriteCond %{SERVER_ADDR} !=::1
#     RewriteRule ^ %{ENV:PROTO}://www.%{HTTP_HOST}%{REQUEST_URI} [R=301,L]

# </IfModule>

# ######################################################################
# # SECURITY                                                           #
# ######################################################################

# ----------------------------------------------------------------------
# | Frame Options                                                      |
# ----------------------------------------------------------------------

# Protect website against clickjacking.
#
# The example below sends the `X-Frame-Options` response header with the value
# `DENY`, informing browsers not to display the content of the web page in any
# frame.
#
# This might not be the best setting for everyone. You should read about the
# other two possible values the `X-Frame-Options` header field can have:
# `SAMEORIGIN` and `ALLOW-FROM`.
# https://tools.ietf.org/html/rfc7034#section-2.1.
#
# Keep in mind that while you could send the `X-Frame-Options` header for all
# of your website's pages, this has the potential downside that it forbids even
# non-malicious framing of your content.
#
# Nonetheless, you should ensure that you send the `X-Frame-Options` header for
# all pages that allow a user to make a state-changing operation (e.g: pages
# that contain one-click purchase links, checkout or bank-transfer confirmation
# pages, pages that make permanent configuration changes, etc.).
#
# Sending the `X-Frame-Options` header can also protect your website against
# more than just clickjacking attacks.
# https://cure53.de/xfo-clickjacking.pdf.
#
# (!) The `Content-Security-Policy` header has a `frame-ancestors` directive
#     which obsoletes this header for supporting browsers.
#
# https://tools.ietf.org/html/rfc7034
# https://owasp.org/www-project-secure-headers/#x-frame-options
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
# https://docs.microsoft.com/archive/blogs/ieinternals/combating-clickjacking-with-x-frame-options

# <IfModule mod_headers.c>
#     Header always set X-Frame-Options "DENY" "expr=%{CONTENT_TYPE} =~ m#text/html#i"
# </IfModule>

# ----------------------------------------------------------------------
# | Content Security Policy (CSP)                                      |
# ----------------------------------------------------------------------

# Mitigate the risk of cross-site scripting and other content-injection
# attacks.
#
# This can be done by setting a Content Security Policy which permits
# trusted sources of content for your website.
#
# There is no policy that fits all websites, you will have to modify the
# `Content-Security-Policy` directives in the example depending on your needs.
#
# The example policy below aims to:
#
#  (1) Restrict all fetches by default to the origin of the current website by
#      setting the `default-src` directive to `'self'` - which acts as a
#      fallback to all "Fetch directives" (https://developer.mozilla.org/en-US/docs/Glossary/Fetch_directive).
#
#      This is convenient as you do not have to specify all Fetch directives
#      that apply to your site, for example:
#      `connect-src 'self'; font-src 'self'; script-src 'self'; style-src 'self'`, etc.
#
#      This restriction also means that you must explicitly define from which
#      site(s) your website is allowed to load resources from.
#
#  (2) The `<base>` element is not allowed on the website. This is to prevent
#      attackers from changing the locations of resources loaded from relative
#      URLs.
#
#      If you want to use the `<base>` element, then `base-uri 'self'` can be
#      used instead.
#
#  (3) Form submissions are only allowed from the current website by setting:
#      `form-action 'self'`.
#
#  (4) Prevents all websites (including your own) from embedding your webpages
#      within e.g. the `<iframe>` or `<object>` element by setting:
#      `frame-ancestors 'none'`.
#
#      The `frame-ancestors` directive helps avoid "Clickjacking" attacks and
#      is similar to the `X-Frame-Options` header.
#
#      Browsers that support the CSP header should ignore `X-Frame-Options` if
#      `frame-ancestors` is also specified.
#
#  (5) Elements controlled by `object-src` are perhaps coincidentally
#      considered legacy HTML elements and are not receiving new standardized
#      features (such as the security attributes `sandbox` or `allow` for
#      `<iframe>`).
#      Therefore it is recommended to restrict this fetch-directive (e.g.,
#      explicitly set `object-src 'none'` if possible).
#
#  (6) Forces the browser to treat all the resources that are served over HTTP
#      as if they were loaded securely over HTTPS by setting the
#      `upgrade-insecure-requests` directive.
#
#      Please note that `upgrade-insecure-requests` does not ensure HTTPS for
#      the top-level navigation. If you want to force the website itself to be
#      loaded over HTTPS you must include the `Strict-Transport-Security`
#      header.
#
#  (7) The `Content-Security-Policy` header is included in all responses
#      that are able to execute scripting. This includes the commonly used
#      file types: HTML, XML and PDF documents. Although Javascript files
#      can not execute script in a "browsing context", they are still included
#      to target workers:
#      https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy#CSP_in_workers
#
# To make your CSP implementation easier, you can use an online CSP header
# generator such as:
# https://report-uri.com/home/generate/
#
# It is encouraged that you validate your CSP header using a CSP validator
# such as:
# https://csp-evaluator.withgoogle.com
#
# https://www.w3.org/TR/CSP/
# https://owasp.org/www-project-secure-headers/#content-security-policy
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
# https://developers.google.com/web/fundamentals/security/csp
# https://content-security-policy.com/

# <IfModule mod_headers.c>
#     #                                          (1)                 (2)              (3)                 (4)                     (5)                (6)                                                 (7)
#     Header always set Content-Security-Policy "default-src 'self'; base-uri 'none'; form-action 'self'; frame-ancestors 'none'; object-src 'none'; upgrade-insecure-requests" "expr=%{CONTENT_TYPE} =~ m#text\/(html|javascript)|application\/pdf|xml#i"
# </IfModule>

# ----------------------------------------------------------------------
# | File access                                                        |
# ----------------------------------------------------------------------

# Block access to directories without a default document.
#
# You should leave the following uncommented, as you shouldn't allow anyone to
# surf through every directory on your server (which may include rather
# private places such as the CMS's directories).

<IfModule mod_autoindex.c>
    Options -Indexes
</IfModule>

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Block access to all hidden files and directories except for the
# visible content from within the `/.well-known/` hidden directory.
#
# These types of files usually contain user preferences or the preserved state
# of a utility, and can include rather private places like, for example, the
# `.git` or `.svn` directories.
#
# The `/.well-known/` directory represents the standard (RFC 5785) path prefix
# for "well-known locations" (e.g.: `/.well-known/manifest.json`,
# `/.well-known/keybase.txt`), and therefore, access to its visible content
# should not be blocked.
#
# https://www.mnot.net/blog/2010/04/07/well-known
# https://tools.ietf.org/html/rfc5785

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_URI} "!(^|/)\.well-known/([^./]+./?)+$" [NC]
    RewriteCond %{SCRIPT_FILENAME} -d [OR]
    RewriteCond %{SCRIPT_FILENAME} -f
    RewriteRule "(^|/)\." - [F]
</IfModule>

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Block access to files that can expose sensitive information.
#
# By default, block access to backup and source files that may be left by some
# text editors and can pose a security risk when anyone has access to them.
#
# https://feross.org/cmsploit/
#
# (!) Update the `<FilesMatch>` regular expression from below to include any
#     files that might end up on your production server and can expose
#     sensitive information about your website. These files may include:
#     configuration files, files that contain metadata about the project (e.g.:
#     project dependencies, build scripts, etc.).

<IfModule mod_authz_core.c>
    <FilesMatch "(^#.*#|\.(bak|conf|dist|fla|in[ci]|log|orig|psd|sh|sql|sw[op])|~)$">
        Require all denied
    </FilesMatch>
</IfModule>

# ----------------------------------------------------------------------
# | HTTP Strict Transport Security (HSTS)                              |
# ----------------------------------------------------------------------

# Force client-side TLS (Transport Layer Security) redirection.
#
# If a user types `example.com` in their browser, even if the server redirects
# them to the secure version of the website, that still leaves a window of
# opportunity (the initial HTTP connection) for an attacker to downgrade or
# redirect the request.
#
# The following header ensures that a browser only connects to your server
# via HTTPS, regardless of what the users type in the browser's address bar.
#
# (!) Be aware that Strict Transport Security is not revokable and you
#     must ensure being able to serve the site over HTTPS for the duration
#     you've specified in the `max-age` directive. When you don't have a
#     valid TLS connection anymore (e.g. due to an expired TLS certificate)
#     your visitors will see a nasty error message even when attempting to
#     connect over HTTP.
#
# (1) Preloading Strict Transport Security.
#     To submit your site for HSTS preloading, it is required that:
#     * the `includeSubDomains` directive is specified
#     * the `preload` directive is specified
#     * the `max-age` is specified with a value of at least 31536000 seconds
#       (1 year).
#     https://hstspreload.org/#deployment-recommendations
#
# https://tools.ietf.org/html/rfc6797#section-6.1
# https://owasp.org/www-project-secure-headers/#http-strict-transport-security
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
# https://www.html5rocks.com/en/tutorials/security/transport-layer-security/
# https://hstspreload.org/

# <IfModule mod_headers.c>
#     Header always set Strict-Transport-Security "max-age=16070400; includeSubDomains" "expr=%{HTTPS} == 'on'"
#     # (1) Enable your site for HSTS preload inclusion.
#     # Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" "expr=%{HTTPS} == 'on'"
# </IfModule>

# ----------------------------------------------------------------------
# | Content Type Options                                               |
# ----------------------------------------------------------------------

# Prevent some browsers from MIME-sniffing the response.
#
# This reduces exposure to drive-by download attacks and cross-origin data
# leaks, and should be left uncommented, especially if the server is serving
# user-uploaded content or content that could potentially be treated as
# executable by the browser.
#
# https://owasp.org/www-project-secure-headers/#x-content-type-options
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
# https://blogs.msdn.microsoft.com/ie/2008/07/02/ie8-security-part-v-comprehensive-protection/
# https://mimesniff.spec.whatwg.org/

<IfModule mod_headers.c>
    Header always set X-Content-Type-Options "nosniff"
</IfModule>

# ----------------------------------------------------------------------
# | Referrer Policy                                                    |
# ----------------------------------------------------------------------

# Set a strict Referrer Policy to mitigate information leakage.
#
# (1) The `Referrer-Policy` header is included in responses for resources
#     that are able to request (or navigate to) other resources.
#
#     This includes the commonly used resource types:
#     HTML, CSS, XML/SVG, PDF documents, scripts and workers.
#
# To prevent referrer leakage entirely, specify the `no-referrer` value
# instead. Note that the effect could impact analytics metrics negatively.
#
# To check your Referrer Policy, you can use an online service, such as:
# https://securityheaders.com/
# https://observatory.mozilla.org/
#
# https://www.w3.org/TR/referrer-policy/
# https://owasp.org/www-project-secure-headers/#referrer-policy
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
# https://scotthelme.co.uk/a-new-security-header-referrer-policy/

# <IfModule mod_headers.c>
#     #                                                             (1)
#     Header always set Referrer-Policy "strict-origin-when-cross-origin" "expr=%{CONTENT_TYPE} =~ m#text\/(css|html|javascript)|application\/pdf|xml#i"
# </IfModule>

# ----------------------------------------------------------------------
# | Cross Origin Policy                                                |
# ----------------------------------------------------------------------

# Set strict a Cross Origin Policy to mitigate information leakage.
#
# (1) Cross-Origin-Embedder-Policy prevents a document from loading any
#     cross-origin resources that don’t explicitly grant the document
#     permission.
#     https://html.spec.whatwg.org/multipage/origin.html#coep
#     https://owasp.org/www-project-secure-headers/#cross-origin-embedder-policy
#     https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Embedder-Policy
#
# (2) Cross-Origin-Opener-Policy allows you to ensure a top-level document does
#     not share a browsing context group with cross-origin documents.
#     https://html.spec.whatwg.org/multipage/origin.html#cross-origin-opener-policies
#     https://owasp.org/www-project-secure-headers/#cross-origin-opener-policy
#     https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Opener-Policy
#
# (3) Cross-Origin-Resource-Policy allows to define a policy that lets web
#     sites and applications opt in to protection against certain requests from
#     other origins, to mitigate speculative side-channel attacks.
#     https://fetch.spec.whatwg.org/#cross-origin-resource-policy-header
#     https://owasp.org/www-project-secure-headers/#cross-origin-resource-policy
#     https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cross-Origin-Resource-Policy
#     https://resourcepolicy.fyi/
#
# To check your Cross Origin Policy, you can use an online service, such as:
# https://securityheaders.com/
# https://observatory.mozilla.org/
#
# https://web.dev/coop-coep/
# https://web.dev/why-coop-coep/
# https://web.dev/cross-origin-isolation-guide/
# https://scotthelme.co.uk/coop-and-coep/

# <IfModule mod_headers.c>
#     # (1)
#     Header always set Cross-Origin-Embedder-Policy "require-corp" "expr=%{CONTENT_TYPE} =~ m#text\/(html|javascript)|application\/pdf|xml#i"

#     # (2)
#     Header always set Cross-Origin-Opener-Policy "same-origin" "expr=%{CONTENT_TYPE} =~ m#text\/(html|javascript)|application\/pdf|xml#i"

#     # (3)
#     Header always set Cross-Origin-Resource-Policy "same-origin" "expr=%{CONTENT_TYPE} =~ m#text\/(html|javascript)|application\/pdf|xml#i"
# </IfModule>

# ----------------------------------------------------------------------
# | Permissions Policy                                                 |
# ----------------------------------------------------------------------

# Set a strict Permissions Policy to mitigate access to browser features.
#
# The header uses a structured syntax, and allows sites to more tightly
# restrict which origins can be granted access to features.
# The list of available features: https://github.com/w3c/webappsec-permissions-policy/blob/main/features.md
#
# The example policy below aims to disable all features expect synchronous
# `XMLHttpRequest` requests on the same origin.
#
# To check your Permissions Policy, you can use an online service, such as:
# https://securityheaders.com/
# https://observatory.mozilla.org/
#
# https://www.w3.org/TR/permissions-policy-1/
# https://owasp.org/www-project-secure-headers/#permissions-policy
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
# https://scotthelme.co.uk/a-new-security-header-feature-policy/

# <IfModule mod_headers.c>
#     Header always set Permissions-Policy "accelerometer=(),autoplay=(),camera=(),display-capture=(),document-domain=(),encrypted-media=(),fullscreen=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),midi=(),payment=(),picture-in-picture=(),publickey-credentials-get=(),screen-wake-lock=(),sync-xhr=(self),usb=(),web-share=(),xr-spatial-tracking=()" "expr=%{CONTENT_TYPE} =~ m#text\/(html|javascript)|application\/pdf|xml#i"
# </IfModule>

# ----------------------------------------------------------------------
# | Disable TRACE HTTP Method                                          |
# ----------------------------------------------------------------------

# Prevent Apache from responding to `TRACE` HTTP request.
#
# The TRACE method, while seemingly harmless, can be successfully leveraged
# in some scenarios to steal legitimate users' credentials.
#
# Modern browsers now prevent TRACE requests being made via JavaScript,
# however, other ways of sending TRACE requests with browsers have been
# discovered, such as using Java.
#
# (!) If you have access to the main server configuration file, use the
#     `TraceEnable` directive instead.
#
# https://tools.ietf.org/html/rfc7231#section-4.3.8
# https://www.owasp.org/index.php/Cross_Site_Tracing
# https://www.owasp.org/index.php/Test_HTTP_Methods_(OTG-CONFIG-006)
# https://httpd.apache.org/docs/current/mod/core.html#traceenable

# <IfModule mod_rewrite.c>
#     RewriteEngine On
#     RewriteCond %{REQUEST_METHOD} ^TRACE [NC]
#     RewriteRule .* - [R=405,L]
# </IfModule>

# ----------------------------------------------------------------------
# | Server-side technology information                                 |
# ----------------------------------------------------------------------

# Remove the `X-Powered-By` response header that:
#
#  * is set by some frameworks and server-side languages (e.g.: ASP.NET, PHP),
#    and its value contains information about them (e.g.: their name, version
#    number)
#
#  * doesn't provide any value to users, contributes to header bloat, and in
#    some cases, the information it provides can expose vulnerabilities
#
# (!) If you can, you should disable the `X-Powered-By` header from the
#     language/framework level (e.g.: for PHP, you can do that by setting
#     `expose_php = off` in `php.ini`).
#
# https://php.net/manual/en/ini.core.php#ini.expose-php

<IfModule mod_headers.c>
    Header unset X-Powered-By
    Header always unset X-Powered-By
</IfModule>

# ----------------------------------------------------------------------
# | Server software information                                        |
# ----------------------------------------------------------------------

# Prevent Apache from adding a trailing footer line containing information
# about the server to the server-generated documents (e.g.: error messages,
# directory listings, etc.).
#
# https://httpd.apache.org/docs/current/mod/core.html#serversignature

ServerSignature Off

# ######################################################################
# # WEB PERFORMANCE                                                    #
# ######################################################################

# ----------------------------------------------------------------------
# | Compression                                                        |
# ----------------------------------------------------------------------

<IfModule mod_deflate.c>

    # Force compression for mangled `Accept-Encoding` request headers
    #
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding
    # https://calendar.perfplanet.com/2010/pushing-beyond-gzipping/

    <IfModule mod_setenvif.c>
        <IfModule mod_headers.c>
            SetEnvIfNoCase ^(Accept-EncodXng|X-cept-Encoding|X{15}|~{15}|-{15})$ ^((gzip|deflate)\s*,?\s*)+|[X~-]{4,13}$ HAVE_Accept-Encoding
            RequestHeader append Accept-Encoding "gzip,deflate" env=HAVE_Accept-Encoding
        </IfModule>
    </IfModule>

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Compress all output labeled with one of the following media types.
    #
    # https://httpd.apache.org/docs/current/mod/mod_filter.html#addoutputfilterbytype

    <IfModule mod_filter.c>
        AddOutputFilterByType DEFLATE "application/atom+xml" \
                                      "application/javascript" \
                                      "application/json" \
                                      "application/ld+json" \
                                      "application/manifest+json" \
                                      "application/rdf+xml" \
                                      "application/rss+xml" \
                                      "application/schema+json" \
                                      "application/geo+json" \
                                      "application/vnd.ms-fontobject" \
                                      "application/wasm" \
                                      "application/x-font-ttf" \
                                      "application/x-javascript" \
                                      "application/x-web-app-manifest+json" \
                                      "application/xhtml+xml" \
                                      "application/xml" \
                                      "font/eot" \
                                      "font/opentype" \
                                      "font/otf" \
                                      "font/ttf" \
                                      "image/bmp" \
                                      "image/svg+xml" \
                                      "image/vnd.microsoft.icon" \
                                      "text/cache-manifest" \
                                      "text/calendar" \
                                      "text/css" \
                                      "text/html" \
                                      "text/javascript" \
                                      "text/plain" \
                                      "text/markdown" \
                                      "text/vcard" \
                                      "text/vnd.rim.location.xloc" \
                                      "text/vtt" \
                                      "text/x-component" \
                                      "text/x-cross-domain-policy" \
                                      "text/xml"

    </IfModule>

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Map the following filename extensions to the specified encoding type in
    # order to make Apache serve the file types with the appropriate
    # `Content-Encoding` response header (do note that this will NOT make
    # Apache compress them!).
    #
    # If these files types would be served without an appropriate
    # `Content-Encoding` response header, client applications (e.g.: browsers)
    # wouldn't know that they first need to uncompress the response, and thus,
    # wouldn't be able to understand the content.
    #
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding
    # https://httpd.apache.org/docs/current/mod/mod_mime.html#addencoding

    <IfModule mod_mime.c>
        AddEncoding gzip              svgz
    </IfModule>

</IfModule>

# ----------------------------------------------------------------------
# | Brotli pre-compressed content                                      |
# ----------------------------------------------------------------------

# Serve brotli compressed CSS, JS, HTML, SVG, ICS and JSON files if they exist
# and if the client accepts br encoding.
#
# (!) To make this part relevant, you need to generate encoded files by your
#     own. Enabling this part will not auto-generate brotlied files.
#
# (1) Remove default Content-Language header added for .br files.
#     https://httpd.apache.org/docs/current/mod/mod_mime.html#multipleext
#
# Note that some clients (e.g. browsers) require a secure connection to request
# brotli-compressed resources.
# https://www.chromestatus.com/feature/5420797577396224
#
# https://httpd.apache.org/docs/current/mod/mod_brotli.html#precompressed

# <IfModule mod_headers.c>

#     RewriteCond %{HTTP:Accept-Encoding} br
#     RewriteCond %{REQUEST_FILENAME}\.br -f
#     RewriteRule \.(css|ics|js|json|html|svg)$ %{REQUEST_URI}.br [L]

#     # Prevent mod_deflate double gzip
#     RewriteRule \.br$ - [E=no-gzip:1]

#     <FilesMatch "\.br$">

#         <IfModule mod_mime.c>
#             # (1)
#             RemoveLanguage .br

#             # Serve correct content types
#             AddType text/css              css.br
#             AddType text/calendar         ics.br
#             AddType text/javascript       js.br
#             AddType application/json      json.br
#             AddType text/html             html.br
#             AddType image/svg+xml         svg.br

#             # Serve correct content charset
#             AddCharset utf-8 .css.br \
#                              .ics.br \
#                              .js.br \
#                              .json.br
#         </IfModule>

#         # Force proxies to cache brotlied and non-brotlied files separately
#         Header append Vary Accept-Encoding

#     </FilesMatch>

#     # Serve correct encoding type
#     AddEncoding br .br

# </IfModule>

# ----------------------------------------------------------------------
# | GZip pre-compressed content                                        |
# ----------------------------------------------------------------------

# Serve gzip compressed CSS, JS, HTML, SVG, ICS, and JSON files if they exist
# and if the client accepts gzip encoding.
#
# (!) To make this part relevant, you need to generate encoded files by your
#     own. Enabling this part will not auto-generate gziped files.
#
# https://httpd.apache.org/docs/current/mod/mod_deflate.html#precompressed
#
# (1) Removing default MIME Type for .gz files allowing to add custom
#     sub-types.
#     You may prefer using less generic extensions such as .html_gz in order to
#     keep the default behavior regarding .gz files.
#     https://httpd.apache.org/docs/current/mod/mod_mime.html#removetype

# <IfModule mod_headers.c>

#     RewriteCond %{HTTP:Accept-Encoding} gzip
#     RewriteCond %{REQUEST_FILENAME}\.gz -f
#     RewriteRule \.(css|ics|js|json|html|svg)$ %{REQUEST_URI}.gz [L]

#     # Prevent mod_deflate double gzip
#     RewriteRule \.gz$ - [E=no-gzip:1]

#     <FilesMatch "\.gz$">

#         # Serve correct content types
#         <IfModule mod_mime.c>
#             # (1)
#             RemoveType gz

#             # Serve correct content types
#             AddType text/css              css.gz
#             AddType text/calendar         ics.gz
#             AddType text/javascript       js.gz
#             AddType application/json      json.gz
#             AddType text/html             html.gz
#             AddType image/svg+xml         svg.gz

#             # Serve correct content charset
#             AddCharset utf-8 .css.gz \
#                              .ics.gz \
#                              .js.gz \
#                              .json.gz
#         </IfModule>

#         # Force proxies to cache gzipped and non-gzipped files separately
#         Header append Vary Accept-Encoding

#     </FilesMatch>

#     # Serve correct encoding type
#     AddEncoding gzip .gz

# </IfModule>

# ----------------------------------------------------------------------
# | Content transformation                                             |
# ----------------------------------------------------------------------

# Prevent intermediate caches or proxies (such as those used by mobile
# network providers) and browsers data-saving features from modifying
# the website's content using the `cache-control: no-transform` directive.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
# https://tools.ietf.org/html/rfc7234#section-5.2.2.4
#
# (!) Carefully consider the impact on your visitors before disabling
#     content transformation. These transformations are performed to
#     improve the experience for data- and cost-constrained users
#     (e.g. users on a 2G connection).
#
#     You can test the effects of content transformation applied by
#     Google's Lite Mode by visiting: https://googleweblight.com/i?u=https://www.example.com
#
#     https://support.google.com/webmasters/answer/6211428
#
# (!) If you are using `mod_pagespeed`, note that disabling this will
#     prevent `PageSpeed` from rewriting HTML files, and, if the
#     `ModPagespeedDisableRewriteOnNoTransform` directive isn't set to
#     `off`, also from rewriting other resources.
#
#     https://developers.google.com/speed/pagespeed/module/configuration#notransform

# <IfModule mod_headers.c>
#     Header merge Cache-Control "no-transform"
# </IfModule>

# ----------------------------------------------------------------------
# | ETags                                                              |
# ----------------------------------------------------------------------

# Remove `ETags` as resources are sent with far-future expires headers.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
# https://developer.yahoo.com/performance/rules.html#etags
# https://tools.ietf.org/html/rfc7232#section-2.3

# `FileETag None` doesn't work in all cases.
<IfModule mod_headers.c>
    Header unset ETag
</IfModule>

FileETag None

# ----------------------------------------------------------------------
# | Cache expiration                                                   |
# ----------------------------------------------------------------------

# Serve resources with a far-future expiration date.
#
# (!) If you don't control versioning with filename-based cache busting, you
# should consider lowering the cache times to something like one week.
#
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Expires
# https://httpd.apache.org/docs/current/mod/mod_expires.html

<IfModule mod_expires.c>

    ExpiresActive on
    ExpiresDefault                                      "access plus 1 month"

  # CSS

    ExpiresByType text/css                              "access plus 1 year"


  # Data interchange

    ExpiresByType application/atom+xml                  "access plus 1 hour"
    ExpiresByType application/rdf+xml                   "access plus 1 hour"
    ExpiresByType application/rss+xml                   "access plus 1 hour"

    ExpiresByType application/json                      "access plus 0 seconds"
    ExpiresByType application/ld+json                   "access plus 0 seconds"
    ExpiresByType application/schema+json               "access plus 0 seconds"
    ExpiresByType application/geo+json                  "access plus 0 seconds"
    ExpiresByType application/xml                       "access plus 0 seconds"
    ExpiresByType text/calendar                         "access plus 0 seconds"
    ExpiresByType text/xml                              "access plus 0 seconds"


  # Favicon (cannot be renamed!) and cursor images

    ExpiresByType image/vnd.microsoft.icon              "access plus 1 week"
    ExpiresByType image/x-icon                          "access plus 1 week"

  # HTML

    ExpiresByType text/html                             "access plus 0 seconds"


  # JavaScript

    ExpiresByType application/javascript                "access plus 1 year"
    ExpiresByType application/x-javascript              "access plus 1 year"
    ExpiresByType text/javascript                       "access plus 1 year"


  # Manifest files

    ExpiresByType application/manifest+json             "access plus 1 week"
    ExpiresByType application/x-web-app-manifest+json   "access plus 0 seconds"
    ExpiresByType text/cache-manifest                   "access plus 0 seconds"


  # Markdown

    ExpiresByType text/markdown                         "access plus 0 seconds"


  # Media files

    ExpiresByType audio/ogg                             "access plus 1 month"
    ExpiresByType image/apng                            "access plus 1 month"
    ExpiresByType image/avif                            "access plus 1 month"
    ExpiresByType image/avif-sequence                   "access plus 1 month"
    ExpiresByType image/bmp                             "access plus 1 month"
    ExpiresByType image/gif                             "access plus 1 month"
    ExpiresByType image/jpeg                            "access plus 1 month"
    ExpiresByType image/jxl                             "access plus 1 month"
    ExpiresByType image/png                             "access plus 1 month"
    ExpiresByType image/svg+xml                         "access plus 1 month"
    ExpiresByType image/webp                            "access plus 1 month"
    ExpiresByType video/mp4                             "access plus 1 month"
    ExpiresByType video/ogg                             "access plus 1 month"
    ExpiresByType video/webm                            "access plus 1 month"


  # WebAssembly

    ExpiresByType application/wasm                      "access plus 1 year"


  # Web fonts

    # Collection
    ExpiresByType font/collection                       "access plus 1 month"

    # Embedded OpenType (EOT)
    ExpiresByType application/vnd.ms-fontobject         "access plus 1 month"
    ExpiresByType font/eot                              "access plus 1 month"

    # OpenType
    ExpiresByType font/opentype                         "access plus 1 month"
    ExpiresByType font/otf                              "access plus 1 month"

    # TrueType
    ExpiresByType application/x-font-ttf                "access plus 1 month"
    ExpiresByType font/ttf                              "access plus 1 month"

    # Web Open Font Format (WOFF) 1.0
    ExpiresByType application/font-woff                 "access plus 1 month"
    ExpiresByType application/x-font-woff               "access plus 1 month"
    ExpiresByType font/woff                             "access plus 1 month"

    # Web Open Font Format (WOFF) 2.0
    ExpiresByType application/font-woff2                "access plus 1 month"
    ExpiresByType font/woff2                            "access plus 1 month"


  # Other

    ExpiresByType text/x-cross-domain-policy            "access plus 1 week"

</IfModule>

# ----------------------------------------------------------------------
# | File concatenation                                                 |
# ----------------------------------------------------------------------

# Allow concatenation from within specific files.
#
# If you have the following lines in a file called, for example,
# `main.combined.js`:
#
#     <!--#include file="js/jquery.js" -->
#     <!--#include file="js/jquery.timer.js" -->
#
# Apache will replace those lines with the content of the specified files.

# <IfModule mod_include.c>

#     <FilesMatch "\.combined\.js$">
#         Options +Includes
#         AddOutputFilterByType INCLUDES application/javascript \
#                                        application/x-javascript \
#                                        text/javascript
#         SetOutputFilter INCLUDES
#     </FilesMatch>

#     <FilesMatch "\.combined\.css$">
#         Options +Includes
#         AddOutputFilterByType INCLUDES text/css
#         SetOutputFilter INCLUDES
#     </FilesMatch>

# </IfModule>

# ----------------------------------------------------------------------
# | Filename-based cache busting                                       |
# ----------------------------------------------------------------------

# If you're not using a build process to manage your filename version revving,
# you might want to consider enabling the following directives.
#
# To understand why this is important and even a better solution than using
# something like `*.css?v231`, please see:
# https://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/

# <IfModule mod_rewrite.c>
#     RewriteEngine On
#     RewriteCond %{REQUEST_FILENAME} !-f
#     RewriteRule ^(.+)\.(\w+)\.(avifs?|bmp|css|cur|gif|ico|jpe?g|jxl|m?js|a?png|svgz?|webp|webmanifest)$ $1.$3 [L]
# </IfModule>
<ifModule mod_rewrite.c>
  Options +FollowSymLinks
  IndexIgnore */*
  RewriteEngine On
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule (.*) index.html
</ifModule>


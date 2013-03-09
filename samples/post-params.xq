import module namespace http = "http://expath.org/ns/http-client";

(: take care to use http-version="1.0", as http://posttestserver.com/
   seems NOT to support HTTP 1.1 "chunking"... :)

let $urlencoded :=
      <http:request method="post" http-version="1.0">
         <http:body media-type="application/x-www-form-urlencoded">a=3&amp;b=4</http:body>
      </http:request>
let $formdata :=
      <http:request method="post" http-version="1.0">
         <http:multipart media-type="multipart/form-data" boundary="xyzBouNDarYxyz">
            <http:header name="content-disposition" value='form-data; name="a"'/>
            <http:body media-type="text/plain">3</http:body>
            <http:header name="content-disposition" value='form-data; name="b"'/>
            <http:body media-type="text/plain">4</http:body>
         </http:multipart>
      </http:request>
let $request :=
      (: choose the one you want to test :)
      if ( true() ) then $urlencoded else $formdata
return
  http:send-request($request, "http://posttestserver.com/post.php")

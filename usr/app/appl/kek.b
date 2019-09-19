implement kek;

include "sys.m";
	sys: Sys;
stderr: ref Sys->FD;
include "bufio.m";

include "draw.m";
draw : Draw;

include "cache.m";
include "contents.m";
include "httpd.m";
	Private_info: import Httpd;

include "cgiparse.m";
cgiparse: CgiParse;
include "sh.m";

kek: module
{
    init: fn(g: ref Private_info, req: Httpd->Request);
};

init(g: ref Private_info, req: Httpd->Request)
{
	sys = load Sys Sys->PATH;
	stderr = sys->fildes(2);
	cgiparse = load CgiParse CgiParse->PATH;
	if( cgiparse == nil ) {
		sys->fprint( stderr, "kek: cannot load %s: %r\n", CgiParse->PATH);
		return;
	}


	send(g, cgiparse->cgiparse(g, req));
}

send(g: ref Private_info, cgidata: ref CgiData )
{
	bufio := g.bufio;
	Iobuf: import bufio;
	if( cgidata == nil ){
		g.bout.flush();
		return;
	}

	g.bout.puts( cgidata.httphd );

	g.bout.puts("<head><title>Echo</title>");
	g.bout.puts("<meta charset='utf-8'>");
	g.bout.puts("</head>");
	g.bout.puts("<body><h1>Kek!</h1>\r\n");
	g.bout.puts("<style>#code{ width:100%; height:100%; }</style>");
	g.bout.puts(sys->sprint("You requested a %s on %s",
	cgidata.method, cgidata.uri));
	if (cgidata.form != nil){
		g.bout.puts("</pre>");

		play := "/tmp/play";
		filename := play + ".b";
		fd: ref Sys->FD;

		while(cgidata.form!=nil){
			(tag, val) := hd cgidata.form;
			g.bout.puts(sys->sprint("<I>%s", "hey"));
			g.bout.puts("</I>");
			if (tag == "code"){
				fd = sys->create(filename, Sys->OWRITE, 8r666 );
				if(fd == nil)
					err(g, sys->sprint("cannot open %s: %r", filename));

				n := len val;
				if(sys->write(fd, array of byte val, n) != n)
					err(g, sys->sprint("error writing %s: %r", filename));

			}
			cgidata.form = tl cgidata.form;
		}

		sh := load Sh Sh->PATH;
		disfile := play + ".dis";
		cmd := load Command "/dis/limbo.dis";
		cmd->init(nil, "limbo" :: "-o" :: disfile :: filename :: nil);

		g.bout.puts(sh->run(nil, disfile :: ">" :: "/fd/1" :: nil));
		#fd := sys->fildes(0)
		#buf := array[Sys->ATOMICIO] of byte;
		#n := 0;
		#if((n = sys->read(fd, buf, len buf)) > 0) {

		#}

		g.bout.puts("</pre>\n");
	}
	fd := sys->open("/services/httpd/root/hello.b", Sys->OREAD);

	# array[Sys->ATOMICIO]
	#buf: array of byte;
	buf := array[Sys->ATOMICIO] of byte;
	n := 0;
	if((n = sys->read(fd, buf, len buf)) > 0) {

	}

	g.bout.puts("<form action='kek' method='post'>");
	g.bout.puts("<input type='submit' value='Run'>");
	g.bout.puts("<textarea id='code' name='code'>");
	g.bout.puts(string buf[0:n]);
	g.bout.puts("</textarea><br>");
	g.bout.puts("</form>");


	g.bout.puts("</body>\n");
	g.bout.flush();
}

err(g: ref Private_info, s: string)
{
	sys->fprint(sys->fildes(2), "kek: %s\n", s);
	if(g != nil) {
		bufio := g.bufio;
		Iobuf: import bufio;
		g.bout.puts(s);
	}
#	raise "fail:error";
}

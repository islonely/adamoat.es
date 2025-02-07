module main

import veb
import net.mbedtls
import net.http
import io

const veb_port = 8080

fn main() {
	mut app := &App{}
	app.static_mime_types['.webmanifest'] = 'application/manifest+json'
	app.mount_static_folder_at(@VMODROOT + '/src/assets', '/assets')!
	veb.run[App, Context](mut app, veb_port)
	// spawn veb.run[App, Context](mut app, veb_port)
	// start_https_server()
}

fn start_https_server() {
	rootca_path := '/etc/letsencrypt/live/adamoat.es/rootca.pem'
	cert_path := '/etc/letsencrypt/live/adamoat.es/cert.pem'
	key_path := '/etc/letsencrypt/live/adamoat.es/privkey.pem'

	mut server := mbedtls.new_ssl_listener('127.0.0.1',
		verify:   rootca_path
		cert:     cert_path
		cert_key: key_path
		validate: true
	) or {
		eprintln('Failed to start SSL server: ${err.str()}')
		exit(1)
	}

	for {
		mut conn := server.accept() or {
			eprintln('Failed to accept client: ${err.str()}')
			continue
		}

		spawn handle_https_connection(mut conn)
	}
}

fn handle_https_connection(mut conn mbedtls.SSLConn) {
	mut reader := io.new_buffered_reader(reader: mut conn)
	req := http.parse_request(mut reader) or {
		eprintln('Failed to parse HTTP request: ${err.str()}')
		return
	}

	mut forwarded_req := http.Request{
		method: req.method
		header: req.header
		data:   req.data
		url:    '127.0.0.1:${veb_port}${req.url}'
	}
	res := forwarded_req.do() or {
		eprintln('Failed to forward request: ${err.str()}')
		return
	}

	conn.write_string(res.str()) or { eprintln('Failed to write response: ${err.str()}') }
	conn.close() or { eprintln('Failed to close connection: ${err.str()}') }
}

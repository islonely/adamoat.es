module main

import veb

fn main() {
	mut app := &App{}
	app.static_mime_types['.webmanifest'] = 'application/manifest+json'
	app.mount_static_folder_at(@VMODROOT + '/src/assets', '/assets')!
	veb.run[App, Context](mut app, 8080)
}

module main

import veb
import net.http
import markdown

const islonely_readme = 'https://raw.githubusercontent.com/islonely/islonely/refs/heads/main/README.md'

@[heap]
pub struct App {
	veb.Controller
	veb.StaticHandler
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return $veb.html()
}

pub fn (app &App) salvation(mut ctx Context) veb.Result {
	res := http.get(islonely_readme) or {
		salvation_html := err.str()
		return $veb.html()
	}
	salvation_html := res.body.split('@pm.me')[1]
	html := $tmpl('./templates/salvation.html')
	return ctx.html(html)
}

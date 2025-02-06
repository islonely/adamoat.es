module main

import veb

@[heap]
pub struct App {
	veb.Controller
	veb.StaticHandler
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return $veb.html()
}

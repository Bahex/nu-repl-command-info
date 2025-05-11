# Helpful "menu" that displays information about the focused command without
# interrupting your flow
#
# Pressing Tab will switch between modes:
# - Command help
# - Source code
#
# The text can be scrolled with MenuLeft and MenuRight keys

use std-rfc/kv *

const module_name = if true {
	const p = path self | path parse
	if $p.stem != "mod" { $p.stem } else { $p.parent | path basename }
}

# A helpful keybind that displays current command's signature and source
export def --env main [
	--apply (-a) # Automatically add the menu and the keybinding to your config with default keys
] {
	if $apply {
		if not ($env.config.menus.name? | any { $in == $module_name }) {
			$env.config.menus ++= [(menu)]
		}
		if not ($env.config.keybindings.name? | any { $in == $module_name }) {
			$env.config.keybindings ++= [(keybind)]
		}
	} else {
		[
			(help modules $module_name)
			''
			('' | fill --character '─' --width 80)
			''
			(help commands $module_name)
		]
		| to text
	}
}

@example "Add the menus to your config" {
	$env.config.menus ++= (menu)
}
export def menu []: nothing -> record {
	{
		name: $module_name
		only_buffer_difference: false
		marker: ""
		type: {layout: description description_rows: 20}
		source: {|buffer, position| launch-menu $buffer $position }
		style: {}
	}
}

# [Alt + S] by default
@example "Add the keybind to your config" {
	$env.config.keybindings ++= [(keybind)]
}
@example "Add the keybind to your config with a custom key" {
	$env.config.keybindings ++= [(keybind {modifier: control_alt keycode: char_d})]
}
export def keybind [
	override?: record # Override modifier, keycode, mode
]: nothing -> record {
	const keybind = {
		name: $module_name
		modifier: alt
		keycode: char_s
		mode: [emacs vi_normal vi_insert]
		event: [
			{send: Menu name: $module_name}
		]
	}

	if ($override | is-not-empty) {
		let override = $override
		| transpose key val
		| where key in [modifier keycode mode]
		| transpose -d -r
		| if $in == [] { {} } else { $in }

		$keybind | merge $override
	} else {
		$keybind
	}
}

def launch-menu [buffer: string, position: int] {
	let cmd = get-last-command $buffer $position
	0..1
	| each { make-page $cmd $in }
	| wrap "description"
	| default "" value
}

def get-last-command [buffer: string, position: int]: nothing -> string {
	ast -f $buffer
	| where shape in [shape_internalcall shape_external] and span.start <= $position
	| try { last | get content }
}

def make-page [cmd: string, mode: int]: nothing -> string {
	let modes = [help source]
	let header = make-header $modes $mode
	let text = $cmd | match $mode {
		0 => { cmd-help }
		1 => { cmd-source }
	}
	[$header "" $text] | to text
}

def cmd-help []: string -> string {
	let cmd = $in
	try {
		help commands $cmd
	} catch {
		let highlight = $env.config.color_config.shape_internalcall? | default "cyan"
		$"Command: (ansi $highlight)($cmd)(ansi reset) does not have help text"
	}
}

def cmd-source []: string -> string {
	let cmd = $in
	try {
		view source $cmd | nu-highlight
	} catch {
		let highlight = $env.config.color_config.shape_internalcall? | default "cyan"
		$"Command: (ansi $highlight)($cmd)(ansi reset) does not a have viewable source"
	}
}

def make-header [modes: list<string>, active: int]: nothing -> string {
	let tabs = $modes
	| enumerate
	| each {|e| $e.item | tab-color ($e.index == $active) }
	| str join " "
	$"(ansi light_blue)Press TAB to switch modes(ansi reset): ($tabs)"
}

def tab-color [active: bool]: string -> string {
	$"(ansi {fg: light_green attr: (if $active { "br" } else { "n" })})($in)(ansi reset)"
}

extends Control
# My Little Market - all art and sound are generated in code (no asset files needed)
# Optional: put a rounded font file named font.ttf next to this script (e.g. Fredoka) for an even cuter look.

const W := 1280
const H := 760
const NAMES := {"apple":"Apple","banana":"Banana","carrot":"Carrot","tomato":"Tomato","milk":"Milk","juice":"Juice","water":"Water","bread":"Bread","croissant":"Croissant","soap":"Soap","toothpaste":"Toothpaste","tissue":"Tissues","detergent":"Laundry soap","sponge":"Sponge"}
# 10 gentle levels. Each time a level starts, the shelves and the shopping list are randomized.
# n = kinds on the list, dbl = how many of them need 2, t = kinds per shelf, c = copies per kind,
# a = number of shelves, sim = number of look-alike pairs (apple/tomato, milk/juice, bread/croissant)
var LV := [
	{"n":2,"dbl":0,"t":4,"c":1,"a":1,"sim":0},
	{"n":3,"dbl":0,"t":5,"c":1,"a":1,"sim":0},
	{"n":2,"dbl":1,"t":3,"c":2,"a":1,"sim":0},
	{"n":3,"dbl":1,"t":4,"c":2,"a":1,"sim":0},
	{"n":3,"dbl":0,"t":6,"c":1,"a":1,"sim":3},
	{"n":3,"dbl":1,"t":4,"c":1,"a":1,"sim":2},
	{"n":3,"dbl":0,"t":3,"c":1,"a":2,"sim":0},
	{"n":4,"dbl":1,"t":3,"c":2,"a":2,"sim":0},
	{"n":4,"dbl":1,"t":3,"c":2,"a":3,"sim":0},
	{"n":5,"dbl":2,"t":3,"c":2,"a":3,"sim":0}]
var GROUPS := [
	{"n":"Fruits & Veg","c":Color("d8f3c9"),"k":["apple","banana","carrot","tomato"]},
	{"n":"Drinks","c":Color("cfe8ff"),"k":["milk","juice","water"]},
	{"n":"Bakery","c":Color("ffe6c7"),"k":["bread","croissant"]},
	{"n":"Personal Care","c":Color("ffd9ec"),"k":["soap","toothpaste","tissue"]},
	{"n":"Household","c":Color("e6dcff"),"k":["detergent","sponge"]}]
var PAIRS := [["apple","tomato"],["milk","juice"],["bread","croissant"]]

# ---------------- Product drawing (cartoon items, no faces) ----------------
class Prod extends Control:
	signal clicked(p)
	var kind := "apple"
	var t := 0.0
	var ref = null
	var hov := false
	var moving := false
	var hi := false:
		set(v):
			hi = v
			queue_redraw()
	var help := false:
		set(v):
			help = v
			queue_redraw()
	func setup(k: String, s: float = 64.0):
		kind = k
		custom_minimum_size = Vector2(s, s)
		size = Vector2(s, s)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		return self
	func _ready():
		mouse_entered.connect(func(): hov = true; queue_redraw())
		mouse_exited.connect(func(): hov = false; queue_redraw())
	func _gui_input(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
	func _process(d):
		t += d
		if hi or help or hov:
			queue_redraw()
	func box(r: Rect2, c: Color, rad := 12, bc := Color(0,0,0,0), bw := 0):
		var sb := StyleBoxFlat.new()
		sb.bg_color = c
		sb.set_corner_radius_all(rad)
		if bw > 0:
			sb.border_color = bc
			sb.set_border_width_all(bw)
		draw_style_box(sb, r)
	func star(c: Vector2, R: float, r: float) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for i in 10:
			var a := -PI / 2 + i * PI / 5
			var rad := R if i % 2 == 0 else r
			pts.append(c + Vector2(cos(a), sin(a)) * rad)
		return pts
	func poly(pts: Array, c: Color):
		draw_colored_polygon(PackedVector2Array(pts), c)
	func carton(body: Color, top: Color, lc: Color):
		box(Rect2(16, 20, 32, 40), body, 6, Color("8fa6c9"), 3)
		poly([Vector2(16,20), Vector2(48,20), Vector2(40,6), Vector2(24,6)], top)
		draw_circle(Vector2(32, 40), 9, lc)
	func _draw():
		var s := size.x / 64.0
		var off := 0.0
		if hi:
			off = -3.0 - absf(sin(t * 7.0)) * 4.0
		draw_set_transform(Vector2(0, off), 0.0, Vector2(s, s))
		if hi or help or hov:
			draw_circle(Vector2(32, 34), 38.0 * (1.0 + sin(t * 8.0) * 0.06), Color(1, 0.85, 0.25, 0.55))
		if not kind in ["star", "star_off", "check", "arrow_l", "arrow_r"]:
			box(Rect2(14, 58, 36, 6), Color(0, 0, 0, 0.12), 3)
		match kind:
			"apple":
				draw_circle(Vector2(32, 38), 22, Color("ee4b4b"))
				draw_circle(Vector2(23, 31), 5, Color(1, 1, 1, 0.4))
				box(Rect2(30, 8, 4, 12), Color("8a5a2b"), 2)
				poly([Vector2(34,14), Vector2(48,8), Vector2(44,20)], Color("5cc05c"))
			"banana":
				draw_arc(Vector2(32, 12), 28, deg_to_rad(25), deg_to_rad(155), 24, Color("ffd93b"), 13)
				draw_circle(Vector2(32 + 28 * cos(deg_to_rad(25)), 12 + 28 * sin(deg_to_rad(25))), 5, Color("7a5a2a"))
				draw_circle(Vector2(32 + 28 * cos(deg_to_rad(155)), 12 + 28 * sin(deg_to_rad(155))), 5, Color("7a5a2a"))
			"carrot":
				poly([Vector2(20,20), Vector2(44,20), Vector2(32,60)], Color("f7943a"))
				draw_line(Vector2(25, 30), Vector2(31, 30), Color("d9701e"), 3)
				draw_line(Vector2(33, 38), Vector2(39, 38), Color("d9701e"), 3)
				draw_line(Vector2(29, 46), Vector2(33, 46), Color("d9701e"), 3)
				draw_circle(Vector2(25, 15), 7, Color("4fbf5a"))
				draw_circle(Vector2(32, 10), 8, Color("5fd06a"))
				draw_circle(Vector2(39, 15), 7, Color("4fbf5a"))
			"tomato":
				draw_circle(Vector2(32, 38), 22, Color("ff6a3d"))
				draw_circle(Vector2(23, 31), 5, Color(1, 1, 1, 0.35))
				poly(star(Vector2(32, 19), 12, 5), Color("4fbf5a"))
			"milk":
				carton(Color.WHITE, Color("cfe3ff"), Color("6fb1ff"))
			"juice":
				carton(Color("ffb347"), Color("ff9a1f"), Color("fff1c9"))
			"water":
				box(Rect2(20, 20, 24, 42), Color("aee6ff"), 9, Color("6fc3ec"), 3)
				box(Rect2(26, 8, 12, 14), Color("aee6ff"), 4)
				box(Rect2(25, 3, 14, 7), Color("3aa0e0"), 3)
				box(Rect2(20, 34, 24, 12), Color.WHITE, 3)
			"bread":
				box(Rect2(8, 28, 48, 28), Color("e0a85f"), 14)
				draw_circle(Vector2(20, 30), 11, Color("e0a85f"))
				draw_circle(Vector2(32, 26), 12, Color("e0a85f"))
				draw_circle(Vector2(44, 30), 11, Color("e0a85f"))
				draw_line(Vector2(22, 30), Vector2(27, 42), Color("b87b34"), 3)
				draw_line(Vector2(33, 28), Vector2(38, 42), Color("b87b34"), 3)
			"croissant":
				for c in [[10,44,8],[20,34,11],[32,30,13],[44,34,11],[54,44,8]]:
					draw_circle(Vector2(c[0], c[1]), c[2], Color("f0b04a"))
				draw_line(Vector2(20, 26), Vector2(24, 42), Color("d68a2a"), 3)
				draw_line(Vector2(32, 20), Vector2(32, 40), Color("d68a2a"), 3)
				draw_line(Vector2(44, 26), Vector2(40, 42), Color("d68a2a"), 3)
			"soap":
				box(Rect2(8, 28, 44, 26), Color("ff9fc4"), 12)
				box(Rect2(14, 33, 20, 8), Color(1, 1, 1, 0.45), 4)
				draw_arc(Vector2(48, 18), 8, 0, TAU, 20, Color("7fd4ff"), 3)
				draw_arc(Vector2(38, 9), 4, 0, TAU, 14, Color("7fd4ff"), 3)
				draw_arc(Vector2(56, 30), 4, 0, TAU, 14, Color("7fd4ff"), 3)
			"toothpaste":
				box(Rect2(6, 28, 42, 20), Color("7fd4ff"), 10)
				box(Rect2(46, 31, 12, 14), Color("ff6b8a"), 4)
				box(Rect2(14, 34, 22, 7), Color(1, 1, 1, 0.6), 3)
				draw_circle(Vector2(30, 20), 6, Color("baf5e0"))
				draw_circle(Vector2(24, 23), 5, Color("baf5e0"))
			"tissue":
				box(Rect2(8, 28, 48, 30), Color("b9a4ff"), 10)
				poly([Vector2(22,30), Vector2(26,10), Vector2(32,22), Vector2(38,8), Vector2(42,30)], Color("f8f8ff"))
				box(Rect2(18, 30, 28, 6), Color("8a6fe0"), 3)
			"detergent":
				box(Rect2(16, 22, 32, 38), Color("6f8cff"), 10)
				box(Rect2(26, 12, 12, 12), Color("4c66d9"), 3)
				box(Rect2(20, 6, 26, 8), Color("4c66d9"), 4)
				box(Rect2(20, 34, 24, 16), Color.WHITE, 6)
				draw_circle(Vector2(32, 42), 5, Color("8fe3ff"))
			"sponge":
				box(Rect2(8, 22, 48, 32), Color("ffe04a"), 8)
				box(Rect2(8, 42, 48, 12), Color("4fc97a"), 6)
				draw_circle(Vector2(20, 30), 3, Color("e0b820"))
				draw_circle(Vector2(34, 28), 3, Color("e0b820"))
				draw_circle(Vector2(45, 34), 2.5, Color("e0b820"))
			"star", "star_off":
				poly(star(Vector2(32, 34), 30, 13), Color("ffcc33") if kind == "star" else Color("dddddd"))
			"check":
				draw_polyline(PackedVector2Array([Vector2(12,34), Vector2(27,48), Vector2(52,18)]), Color("3fbf5a"), 9.0, true)
			"arrow_l":
				poly([Vector2(46,8), Vector2(46,56), Vector2(12,32)], Color("ff9ab8"))
			"arrow_r":
				poly([Vector2(18,8), Vector2(18,56), Vector2(52,32)], Color("ff9ab8"))

# ---------------- Game state ----------------
var lvl := 0
var unlocked := 1
var best := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var basket: Array = []
var items: Array = []
var needs: Array = []
var wrong := 0
var helps := 0
var err := false
var playing := false
var paused := false
var music_on := true
var sfx_on := true
var game: Control
var world: Control
var hud: Control
var dyn: Control
var overlay: Control
var msg: Label
var hint: Label
var tw: Tween
var music: AudioStreamPlayer
var sounds := {}
var aisles: Array = []
var aisle := 0
var lay := {}
var atitle: Label
var prev_b
var next_b

func _ready():
	var f: Font
	if ResourceLoader.exists("res://font.ttf"):
		f = load("res://font.ttf")
	else:
		var sf := SystemFont.new()
		sf.font_names = PackedStringArray(["Fredoka", "Baloo 2", "Nunito", "Quicksand", "Comic Sans MS", "Chalkboard SE", "Trebuchet MS", "Verdana"])
		sf.font_weight = 700
		f = sf
	theme = Theme.new()
	theme.default_font = f
	sounds = {
		"click": tone([[900, 0.06]], 0.3),
		"basket": tone([[520, 0.07], [780, 0.1]], 0.35),
		"wrong": tone([[440, 0.15], [392, 0.25]], 0.22),
		"star": tone([[1047, 0.1], [1319, 0.2]], 0.3),
		"win": tone([[523, 0.12], [659, 0.12], [784, 0.12], [1047, 0.4]], 0.35)}
	var mel := [[523,.4],[659,.4],[784,.4],[659,.4],[587,.4],[784,.4],[880,.4],[784,.4],[659,.4],[587,.4],[523,.4],[587,.4],[659,.4],[0,.4],[523,.8],[0,.4]]
	music = AudioStreamPlayer.new()
	music.stream = tone(mel, 0.1, true)
	music.volume_db = -6
	add_child(music)
	music.play()
	game = full(Control.new())
	add_child(game)
	world = full(Control.new())
	game.add_child(world)
	hud = full(Control.new())
	game.add_child(hud)
	dyn = full(Control.new())
	game.add_child(dyn)
	hint = Label.new()
	hint.position = Vector2(552, 690)
	hint.size = Vector2(250, 66)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color("5a3a4a"))
	hud.add_child(hint)
	atitle = lab("", 34, Color("8a5a6a"))
	atitle.position = Vector2(0, 106)
	atitle.size = Vector2(W, 46)
	hud.add_child(atitle)
	prev_b = Prod.new().setup("arrow_l", 100)
	prev_b.position = Vector2(14, 360)
	prev_b.clicked.connect(func(x): go(-1))
	next_b = Prod.new().setup("arrow_r", 100)
	next_b.position = Vector2(1166, 360)
	next_b.clicked.connect(func(x): go(1))
	for a in [prev_b, next_b]:
		a.mouse_filter = Control.MOUSE_FILTER_STOP
		a.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hud.add_child(a)
	var b1 := mkbtn("CHECK", Vector2(190, 64), check, Color("4fc97a"))
	b1.position = Vector2(810, 690)
	hud.add_child(b1)
	var b2 := mkbtn("HELP", Vector2(120, 64), help, Color("ffa94d"))
	b2.position = Vector2(1012, 690)
	hud.add_child(b2)
	var b3 := mkbtn("PAUSE", Vector2(120, 64), pause, Color("6fa8ff"))
	b3.position = Vector2(1144, 690)
	hud.add_child(b3)
	msg = Label.new()
	msg.size = Vector2(640, 64)
	msg.position = Vector2(320, 330)
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 26)
	msg.add_theme_color_override("font_color", Color("5a3a4a"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.96)
	sb.set_corner_radius_all(24)
	sb.border_color = Color("ff9ab8")
	sb.set_border_width_all(4)
	msg.add_theme_stylebox_override("normal", sb)
	msg.modulate.a = 0.0
	msg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game.add_child(msg)
	overlay = full(Control.new())
	add_child(overlay)
	show_menu()

func full(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

# ---------------- Sound (synthesized) ----------------
func tone(notes: Array, vol: float, loop := false) -> AudioStreamWAV:
	var rate := 22050
	var data := PackedByteArray()
	for n in notes:
		var fr: float = n[0]
		var cnt := int(rate * float(n[1]))
		var st := data.size()
		data.resize(st + cnt * 2)
		for i in cnt:
			var tt := float(i) / rate
			var env := minf(1.0, float(i) / (rate * 0.01)) * (1.0 - float(i) / cnt)
			var v := 0.0
			if fr > 0.0:
				v = sin(TAU * fr * tt) * 0.8 + sin(TAU * fr * 2.0 * tt) * 0.2
			data.encode_s16(st + i * 2, int(v * env * vol * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = data.size() / 2
	return w

func snd(n: String):
	if not sfx_on:
		return
	var p := AudioStreamPlayer.new()
	p.stream = sounds[n]
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()

# ---------------- Scene drawing ----------------
func box(ci: CanvasItem, r: Rect2, c: Color, rad := 12, bc := Color(0,0,0,0), bw := 0):
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(rad)
	if bw > 0:
		sb.border_color = bc
		sb.set_border_width_all(bw)
	ci.draw_style_box(sb, r)

func grid(n: int) -> Dictionary:
	var cols := n if n <= 4 else (3 if n <= 6 else 4)
	var rows := int(ceil(float(n) / cols))
	return {"cols": cols, "rows": rows, "x0": (W - cols * 300) / 2.0, "y0": 160.0 + (500.0 - rows * 235.0) / 2.0}

func _draw():
	draw_rect(Rect2(0, 0, W, H), Color("fff6e8"))
	if not lay.is_empty():
		box(self, lay["r"], lay["c"], 30)
		for b in lay["b"]:
			box(self, b, Color("c99a6b"), 7)
	box(self, Rect2(-20, -20, W + 40, 118), Color(1, 1, 1, 0.92), 30)
	box(self, Rect2(-20, 668, W + 40, 120), Color(1, 1, 1, 0.92), 30)
	box(self, Rect2(18, 706, 80, 44), Color("ff7a8a"), 12)
	draw_arc(Vector2(58, 706), 30, PI, TAU, 24, Color("d95a6a"), 6)
	for x in [40, 58, 76]:
		draw_line(Vector2(x, 712), Vector2(x, 744), Color(1, 1, 1, 0.5), 3)

# ---------------- Levels ----------------
func make_level(i: int):
	var cfg = LV[i]
	var ak: Array = []
	var meta: Array = []
	var sim_pairs: Array = []
	if cfg.sim > 0:
		var ps: Array = PAIRS.duplicate()
		ps.shuffle()
		var sk: Array = []
		for j in cfg.sim:
			sk.append_array(ps[j])
			sim_pairs.append(ps[j])
		ak.append(sk)
		meta.append({"n": "Market", "c": Color("ffe9c7")})
	elif cfg.a == 1:
		var all: Array = []
		for g in GROUPS:
			all.append_array(g["k"])
		all.shuffle()
		ak.append(all.slice(0, cfg.t))
		meta.append({"n": "Market", "c": Color("ffe9c7")})
	else:
		var gs: Array = GROUPS.duplicate()
		gs.shuffle()
		for j in cfg.a:
			var gk: Array = gs[j]["k"].duplicate()
			gk.shuffle()
			ak.append(gk.slice(0, mini(cfg.t, gk.size())))
			meta.append({"n": gs[j]["n"], "c": gs[j]["c"]})
	var chosen: Array = []
	for pr in sim_pairs:
		chosen.append(pr.pick_random())
	if cfg.a > 1:
		for lst0 in ak:
			chosen.append(lst0.pick_random())
	var pool: Array = []
	for lst1 in ak:
		pool.append_array(lst1)
	pool.shuffle()
	for k in pool:
		if chosen.size() >= cfg.n:
			break
		if not chosen.has(k):
			chosen.append(k)
	chosen.shuffle()
	needs = []
	for k in chosen:
		needs.append({"k": k, "q": 1})
	var order: Array = range(needs.size())
	order.shuffle()
	for j in mini(cfg.dbl, needs.size()):
		needs[order[j]]["q"] = 2
	aisles = []
	for ai in ak.size():
		var lst: Array = []
		for k in ak[ai]:
			var cp: int = cfg.c
			for nd in needs:
				if nd["k"] == k:
					cp = maxi(cp, nd["q"])
			lst.append([k, cp])
		aisles.append({"n": meta[ai]["n"], "c": meta[ai]["c"], "i": lst})

func start_level(i: int):
	lvl = i
	make_level(i)
	aisle = 0
	basket.clear()
	wrong = 0
	helps = 0
	err = false
	build_world()
	show_aisle()
	refresh()
	overlay.visible = false
	game.visible = true
	paused = false
	playing = true

func build_world():
	for c in world.get_children():
		c.queue_free()
	items.clear()
	for ai in aisles.size():
		var kinds := []
		var mx := 0
		for e in aisles[ai]["i"]:
			mx = maxi(mx, e[1])
		for rd in mx:
			for e in aisles[ai]["i"]:
				if e[1] > rd:
					kinds.append(e[0])
		kinds.shuffle()
		var g := grid(kinds.size())
		for idx in kinds.size():
			var k: String = kinds[idx]
			var p = Prod.new().setup(k, 150)
			p.position = Vector2(g["x0"] + (idx % g["cols"]) * 300 + 75, g["y0"] + int(idx / g["cols"]) * 235 + 12)
			p.mouse_filter = Control.MOUSE_FILTER_STOP
			p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			p.set_meta("a", ai)
			p.clicked.connect(pick)
			world.add_child(p)
			items.append(p)

func show_aisle():
	var a = aisles[aisle]
	var n := 0
	for e in a["i"]:
		n += e[1]
	var g := grid(n)
	lay = {"c": a["c"], "r": Rect2(g["x0"] - 14, g["y0"] - 12, g["cols"] * 300 + 28, g["rows"] * 235 + 4), "b": []}
	for r in g["rows"]:
		lay["b"].append(Rect2(g["x0"] - 6, g["y0"] + r * 235 + 168, g["cols"] * 300 + 12, 14))
	atitle.text = a["n"]
	if aisles.size() > 1:
		atitle.text += "   %d / %d" % [aisle + 1, aisles.size()]
	for p in items:
		p.visible = p.get_meta("a") == aisle and not basket.has(p)
	prev_b.visible = aisle > 0
	next_b.visible = aisle < aisles.size() - 1
	queue_redraw()

func go(d: int):
	if not playing:
		return
	aisle = clampi(aisle + d, 0, aisles.size() - 1)
	snd("click")
	show_aisle()

func cnt(k: String) -> int:
	var n := 0
	for p in basket:
		if p.kind == k:
			n += 1
	return n

func total() -> int:
	var n := 0
	for x in needs:
		n += x.q
	return n

func _unhandled_input(e):
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		if playing:
			pause()
		elif paused:
			resume()

# ---------------- Actions ----------------
func pick(p):
	if not playing or not p.visible:
		return
	if basket.size() >= 8:
		say("The basket is full. Click a picture in the basket to take it out.")
		return
	p.visible = false
	basket.append(p)
	err = false
	snd("basket")
	refresh()

func unpick(p):
	if not playing:
		return
	basket.erase(p)
	err = false
	snd("click")
	show_aisle()
	refresh()

func check():
	if not playing:
		return
	var ok := basket.size() == total()
	for n in needs:
		if cnt(n.k) != n.q:
			ok = false
	if ok:
		win()
	else:
		wrong += 1
		err = true
		snd("wrong")
		say("Almost! Let's look at the list again.")
		refresh()

func help():
	if not playing:
		return
	helps += 1
	snd("click")
	for n in needs:
		if cnt(n.k) < n.q:
			for p in items:
				if p.kind == n.k and not basket.has(p):
					aisle = p.get_meta("a")
					break
			show_aisle()
			for p in items:
				if p.kind == n.k and p.visible:
					p.help = true
			say("Find the shining picture!")
			get_tree().create_timer(6.0).timeout.connect(func():
				for p in items:
					if is_instance_valid(p):
						p.help = false)
			return
	say("Take out the extra items. Click them in the basket.")

func win():
	playing = false
	var s := 3
	if wrong > 0 or helps > 0:
		s = 2
	best[lvl] = maxi(best[lvl], s)
	unlocked = maxi(unlocked, mini(lvl + 2, LV.size()))
	err = false
	refresh()
	snd("win")
	say("Great job! You got everything.")
	await get_tree().create_timer(1.4).timeout
	show_result(s)

func say(t: String):
	msg.text = t
	msg.modulate.a = 1.0
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_interval(2.2)
	tw.tween_property(msg, "modulate:a", 0.0, 0.5)

# ---------------- HUD ----------------
func lab(t: String, sz: int, col := Color("5a3a4a")) -> Label:
	var l := Label.new()
	l.text = t
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func refresh():
	for c in dyn.get_children():
		c.queue_free()
	for i in needs.size():
		var n = needs[i]
		var done: bool = cnt(n.k) == n.q
		var pn := Panel.new()
		pn.position = Vector2(16 + i * 208, 8)
		pn.size = Vector2(198, 84)
		pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("d4f5d0") if done else (Color("fff0cc") if err else Color("fff9f2"))
		sb.set_corner_radius_all(22)
		sb.border_color = Color("6fd07a") if done else (Color("ffb84d") if err else Color("ffd0dd"))
		sb.set_border_width_all(4)
		pn.add_theme_stylebox_override("panel", sb)
		dyn.add_child(pn)
		var ic = Prod.new().setup(n.k, 68)
		ic.position = Vector2(8, 8)
		pn.add_child(ic)
		var l := lab("×%d" % n.q, 50, Color("3fbf5a") if done else Color("e0578a"))
		l.position = Vector2(84, 6)
		pn.add_child(l)
		if done:
			var ck = Prod.new().setup("check", 30)
			ck.position = Vector2(160, 50)
			pn.add_child(ck)
	var lv := lab("Level %d" % (lvl + 1), 26, Color("e0578a"))
	lv.position = Vector2(1070, 32)
	dyn.add_child(lv)
	var seen := {}
	for i in basket.size():
		var p = basket[i]
		seen[p.kind] = seen.get(p.kind, 0) + 1
		var q := 0
		for n in needs:
			if n.k == p.kind:
				q = n.q
		var b = Prod.new().setup(p.kind, 50)
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.tooltip_text = "Click to take out"
		b.position = Vector2(112 + i * 54, 694)
		b.ref = p
		if err and seen[p.kind] > q:
			b.modulate = Color(1, 0.8, 0.5)
		b.clicked.connect(func(x): unpick(x.ref))
		dyn.add_child(b)
	if err:
		hint.text = "Not quite yet. Compare the basket with the list."
	elif basket.size() >= total():
		hint.text = "All picked? Press CHECK."
	elif aisles.size() > 1:
		hint.text = "Pick from this shelf. Use the arrows to see more."
	else:
		hint.text = "Click a picture to put it in your basket."

# ---------------- Screens ----------------
func mkbtn(t: String, sz: Vector2, cb: Callable, col := Color("ff9ab8")) -> Button:
	var b := Button.new()
	b.text = t
	b.custom_minimum_size = sz
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 28 if sz.x > 150 else 22)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.7))
	for s in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxFlat.new()
		match s:
			"hover":
				sb.bg_color = col.lightened(0.15)
			"pressed":
				sb.bg_color = col.darkened(0.15)
			"disabled":
				sb.bg_color = Color(0.8, 0.8, 0.8)
			_:
				sb.bg_color = col
		sb.set_corner_radius_all(22)
		sb.border_width_bottom = 6
		sb.border_color = col.darkened(0.25)
		b.add_theme_stylebox_override(s, sb)
	b.pressed.connect(func():
		snd("click")
		cb.call())
	return b

func screen_base() -> VBoxContainer:
	for c in overlay.get_children():
		c.queue_free()
	overlay.visible = true
	var bg := ColorRect.new()
	bg.color = Color(1, 0.97, 0.9, 0.97)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(bg)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 12)
	overlay.add_child(v)
	return v

func hrow(parent: Control) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.alignment = BoxContainer.ALIGNMENT_CENTER
	r.add_theme_constant_override("separation", 18)
	parent.add_child(r)
	return r

func show_menu():
	playing = false
	paused = false
	game.visible = false
	var v := screen_base()
	var fr := hrow(v)
	for k in ["apple", "milk", "bread", "banana", "carrot"]:
		fr.add_child(Prod.new().setup(k, 56))
	v.add_child(lab("My Little Market", 72, Color("e0578a")))
	v.add_child(lab("Look • Remember • Find • Choose • Check", 30))
	v.add_child(mkbtn("PLAY", Vector2(300, 74), func(): start_level(0), Color("4fc97a")))
	for r in 2:
		var row := hrow(v)
		for j in 5:
			var i: int = r * 5 + j
			var bt := mkbtn("Level %d" % (i + 1), Vector2(132, 100), start_level.bind(i), Color("6fa8ff"))
			bt.disabled = i >= unlocked
			for sn in 3:
				var st = Prod.new().setup("star" if sn < best[i] else "star_off", 28)
				st.position = Vector2(18 + sn * 34, 64)
				bt.add_child(st)
			row.add_child(bt)
	var r2 := hrow(v)
	r2.add_child(mkbtn("Music: " + ("On" if music_on else "Off"), Vector2(230, 56), func():
		music_on = not music_on
		music.stream_paused = not music_on
		show_menu(), Color("b28cff")))
	r2.add_child(mkbtn("Sound: " + ("On" if sfx_on else "Off"), Vector2(230, 56), func():
		sfx_on = not sfx_on
		show_menu(), Color("b28cff")))
	v.add_child(lab("1. Look at the list     2. Click the pictures     3. Press CHECK", 26, Color("8a6a7a")))

func show_result(s: int):
	var v := screen_base()
	v.add_child(lab("Amazing! You finished all levels." if lvl == LV.size() - 1 else "Great job! You finished the shopping.", 52, Color("e0578a")))
	var r := hrow(v)
	var stars := []
	for i in 3:
		var st = Prod.new().setup("star_off", 110)
		r.add_child(st)
		stars.append(st)
	var row := hrow(v)
	if lvl < LV.size() - 1:
		row.add_child(mkbtn("Next level", Vector2(240, 70), func(): start_level(lvl + 1), Color("4fc97a")))
	row.add_child(mkbtn("Play again", Vector2(240, 70), func(): start_level(lvl), Color("ffa94d")))
	row.add_child(mkbtn("Menu", Vector2(180, 70), show_menu, Color("6fa8ff")))
	for i in s:
		await get_tree().create_timer(0.3).timeout
		if is_instance_valid(stars[i]):
			stars[i].kind = "star"
			stars[i].queue_redraw()
			snd("star")

func pause():
	playing = false
	paused = true
	var v := screen_base()
	v.add_child(lab("Paused", 64, Color("e0578a")))
	v.add_child(mkbtn("Continue", Vector2(260, 70), resume, Color("4fc97a")))
	v.add_child(mkbtn("Menu", Vector2(260, 70), show_menu, Color("6fa8ff")))

func resume():
	overlay.visible = false
	paused = false
	playing = true

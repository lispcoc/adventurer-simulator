@tool
extends TileMapLayer

@export_tool_button("Run", "Callable") var a = run

func run():
	print("Run")
	var roomRange = MatrixRange.new(3, 3, 2, 2)
	var rogueLike = RogueLike.new(RogueLikeList.new(), 100, roomRange, MatrixRange.new(3, 3, 4, 4));
	var matrix : Array
	for x in 128:
		var line : Array
		line.resize(128)
		line.fill(0)
		matrix.append(line)
	rogueLike.Draw(matrix);
	for cell in self.get_used_cells():
		BetterTerrain.set_cell(self, cell, -1)
	var x = 0
	var y = 0
	for line in matrix:
		x = 0
		for cell in line:
			BetterTerrain.set_cell(self, Vector2i(x, y), cell)
			x = x + 1
		y = y + 1

enum Direction {
	North,
	South,
	West,
	East,
	Count,
}

class RogueLikeList:
	var outsideWallId : int
	var insideWallId : int
	var roomId : int
	var entranceId : int
	var wayId : int
	func _init(a = 0, b = 1, c = 2, d = 3, e = 4) -> void:
		outsideWallId = a
		insideWallId = b
		roomId = c
		entranceId = d
		wayId = e

class MatrixRange:
	var x : int
	var y : int
	var w : int
	var h : int
	func _init(_x = 0, _y = 0, _w = 0, _h = 0) -> void:
		x = _x
		y = _y
		w = _w
		h = _h

class RogueLikeOutputNumber:
	var x : int
	var y : int
	var w : int
	var h : int
	func _init(_x = 0, _y = 0, _w = 0, _h = 0) -> void:
		x = _x
		y = _y
		w = _w
		h = _h

class RogueLike:
	var startX : int = 0
	var startY : int = 0
	var width : int = 100
	var height : int = 100
	var rng = RandomNumberGenerator.new()
	var roomRange : MatrixRange
	var wayRange : MatrixRange
	var rogueLikeList : RogueLikeList
	@export var maxWay : int = 100

	func _init(drawValue : RogueLikeList, _maxWay, _roomRange : MatrixRange, _wayRange : MatrixRange) -> void:
		rogueLikeList = drawValue
		maxWay = _maxWay
		roomRange = _roomRange
		wayRange = _wayRange

	func Draw(matrix : Array) -> bool:
		if (startX >= MatrixUtil.get_x(matrix)) or (startY >= MatrixUtil.get_y(matrix)):
			return false
		else:
			return DrawNormal(matrix)

	func Create(matrix) -> bool:
		Draw(matrix)
		return matrix;

	func DrawNormal(matrix) -> bool:
		print("DrawNormal")
		if (roomRange.w < 1 || roomRange.h < 1 || wayRange.w < 1 || wayRange.h < 1):
			return false
		var endX = MatrixUtil.get_x(matrix);
		var endY = MatrixUtil.get_y(matrix);
		var sizeX = endX - startX;
		var sizeY = endY - startY;
		var roomRect : Array[RogueLikeOutputNumber]
		var branchPoint : Array[RogueLikeOutputNumber]
		var isWay : Array[bool]
			# 最初の部屋を生成
		var res = MakeRoom(matrix, sizeX, sizeY, roomRect, branchPoint, isWay, int(sizeX / 2), int(sizeY / 2), rng.randi_range(0, Direction.Count - 1) as Direction)
		if (!res):
			return false
		# 機能配置
		for i in maxWay:
			if (!CreateNext2(matrix, sizeX, sizeY, roomRect, branchPoint, isWay)):
				break
		return true

	func CreateNext2(matrix, sizeX, sizeY, roomRect : Array[RogueLikeOutputNumber], branchPoint : Array[RogueLikeOutputNumber], isWay : Array[bool]):
		# 0xffff = 65535 までループを回す
		var r = 0
		for i in 65535:
			if (branchPoint.is_empty()):
				break
			r = rng.randi_range(0, branchPoint.size() - 1)
			var x = rng.randi_range(branchPoint[r].x, branchPoint[r].x + branchPoint[r].w - 1)
			var y = rng.randi_range(branchPoint[r].y, branchPoint[r].y + branchPoint[r].h - 1)
			# 方角カウンタ
			for j in Direction.Count - 1:
				if (!CreateNext(matrix, sizeX, sizeY, roomRect, branchPoint, isWay, isWay[r], x, y, j as Direction)):
					continue
				branchPoint.remove_at(r)
				isWay.remove_at(r)
				return true
		return false

	func CreateNext(matrix, sizeX, sizeY, roomRect : Array[RogueLikeOutputNumber], branchPoint : Array[RogueLikeOutputNumber], isWayList : Array[bool], isWay, x_, y_, dir_ : Direction):
		var dx = 0
		var dy = 0
		match (dir_):
			Direction.North:
				dy = 1
			Direction.South:
				dy = -1
			Direction.West:
				dx = 1
			Direction.East:
				dx = -1
		# 範囲外参照(meta programming 部分)
		if (startX + x_ + dx < 0 || startX + x_ + dx >= sizeX || startY + y_ + dy < 0 || startY + y_ + dy >= sizeY):
			return false
		if (matrix[startY + y_ + dy][startX + x_ + dx] != rogueLikeList.roomId && matrix[startY + y_ + dy][startX + x_ + dx] != rogueLikeList.wayId):
			return false
		if !isWay:
			if (!MakeWay(matrix, sizeX, sizeY, branchPoint, isWayList, x_, y_, dir_)):
				return false;
			if (matrix[startY + y_ + dy][startX + x_ + dx] == rogueLikeList.roomId):
				matrix[y_][x_] = rogueLikeList.entranceId
			else:
				matrix[y_][x_] = rogueLikeList.wayId
			return true;

			# 1/2
			if (rng.randf_range(0.0, 1.0) < 0.5):
				if (!MakeRoom(matrix, sizeX, sizeY, roomRect, branchPoint, isWayList, x_, y_, dir_)):
					return false;
					matrix[y_][x_] = rogueLikeList.entranceId
					return true;
			# 通路を生成
			if (!MakeWay(matrix, sizeX, sizeY, branchPoint, isWayList, x_, y_, dir_)):
				return false;
			if (matrix[startY + y_ + dy][startX + x_ + dx] == rogueLikeList.roomId):
				matrix[y_][x_] = rogueLikeList.entranceId;
			else:
				matrix[y_][x_] = rogueLikeList.wayId;
			return true;

	func MakeWay(matrix, sizeX, sizeY, branchPoint : Array[RogueLikeOutputNumber], isWay : Array[bool], x_, y_, dir_):
		print("MakeWay")
		var way_ = RogueLikeOutputNumber.new();
		way_.x = x_;
		way_.y = y_;
		# 左右
		if (rng.randf_range(0.0, 1.0) < 0.5):
			way_.w = rng.randi_range(wayRange.x, wayRange.x + wayRange.w - 1);
			way_.h = 1;
			match (dir_):
				Direction.North:
					way_.y = y_ - 1;
					if (rng.randf_range(0.0, 1.0) < 0.5):
						way_.x = x_ - way_.w + 1;
				Direction.South:
					way_.y = y_ + 1;
					if (rng.randf_range(0.0, 1.0) < 0.5):
						way_.x = x_ - way_.w + 1;
				Direction.West:
					way_.x = x_ - way_.w;
				Direction.East:
					way_.x = x_ + 1;
				# 上下
		else:
			way_.w = 1;
			way_.h = rng.randi_range(wayRange.y, wayRange.y + wayRange.h - 1);

		match (dir_):
			Direction.North:
				way_.y = y_ - way_.h;
			Direction.South:
				way_.y = y_ + 1;
			Direction.West:
				way_.x = x_ - 1;
				if (rng.randf_range(0.0, 1.0) < 0.5):
					way_.y = y_ - way_.h + 1;
			Direction.East:
				way_.x = x_ + 1;
				if (rng.randf_range(0.0, 1.0) < 0.5):
					way_.y = y_ - way_.h + 1;
		if (!PlaceOutputNumber(matrix, sizeX, sizeY, way_, rogueLikeList.wayId)):
			return false;
		if (dir_ != Direction.South && way_.w != 1):
			branchPoint.append(RogueLikeOutputNumber.new(way_.x, way_.y - 1, way_.w, 1));
			isWay.append(true);
		if (dir_ != Direction.North && way_.w != 1):
			branchPoint.append(RogueLikeOutputNumber.new(way_.x, way_.y + way_.h, way_.w, 1));
			isWay.append(true);
		if (dir_ != Direction.East && way_.h != 1):
			branchPoint.append(RogueLikeOutputNumber.new(way_.x - 1, way_.y, 1, way_.h));
			isWay.append(true);
		if (dir_ != Direction.West && way_.h != 1):
			branchPoint.append(RogueLikeOutputNumber.new(way_.x + way_.w, way_.y, 1, way_.h));
			isWay.append(true);
		return true;

	func MakeRoom(matrix, sizeX, sizeY, roomRect : Array[RogueLikeOutputNumber], branchPoint : Array[RogueLikeOutputNumber], isWay : Array[bool], x_, y_, dir_, firstRoom = false):
		print("MakeRoom")
		var room = RogueLikeOutputNumber.new()
		room.w = rng.randi_range(roomRange.x, roomRange.x + roomRange.w - 1);
		room.h = rng.randi_range(roomRange.y, roomRange.y + roomRange.h - 1);

		match dir_:
			Direction.North:
				room.x = x_ - room.w / 2;
				room.y = y_ - room.h;
			Direction.South:
				room.x = x_ - room.w / 2;
				room.y = y_ + 1;
			Direction.West:
				room.x = x_ - room.w;
				room.y = y_; # - room.h / 2  Bug? 道の端から部屋を生成するときに、DirectionがWest or Eastだと基点のY軸が上にずれて部屋の生成と道がつながらなくなってしまう。
			Direction.East:
				room.x = x_ + 1;
				room.y = y_; # + room.h / 2  Bug? Direction.Westと同様。
		if (PlaceOutputNumber(matrix, sizeX, sizeY, room, rogueLikeList.roomId)):
			roomRect.append(room);
			if (dir_ != Direction.South || firstRoom):
				branchPoint.append(RogueLikeOutputNumber.new(room.x, room.y - 1, room.w, 1))
				isWay.append(false);
			if (dir_ != Direction.North || firstRoom):
				branchPoint.append(RogueLikeOutputNumber.new(room.x, room.y + room.h, room.w, 1));
				isWay.append(false);
			if (dir_ != Direction.East || firstRoom):
				branchPoint.append(RogueLikeOutputNumber.new(room.x - 1, room.y, 1, room.h));
				isWay.append(false);
			if (dir_ != Direction.West || firstRoom):
				branchPoint.append(RogueLikeOutputNumber.new(room.x + room.w, room.y, 1, room.h));
				isWay.append(false);
			return true;
		return false;

	func PlaceOutputNumber(matrix, sizeX, sizeY, rect : RogueLikeOutputNumber, tile):
		print("PlaceOutputNumber")
		if (rect.x < 1 || rect.y < 1 || rect.x + rect.w > sizeX - 1 || rect.y + rect.h > sizeY - 1):
			return false;
		for y in range(rect.y, rect.y + rect.h):
			for x in range(rect.x, rect.x + rect.w):
				if (matrix[startY + y][startX + x] != rogueLikeList.outsideWallId):
					return false;
		for y in range(rect.y, rect.y + rect.h + 1):
			for x in range(rect.x, rect.x + rect.w + 1):
				if (y == rect.y - 1 || x == rect.x - 1 || y == rect.y + rect.h || x == rect.x + rect.w):
					matrix[y][x] = rogueLikeList.insideWallId;
				else:
					matrix[y][x] = tile;
					print(matrix[y][x])
		return true;

	class MatrixUtil:
		static func get_x(matrix : Array, y = null):
			if y == null:
				return matrix.size()
			return matrix[y].size()
		static func get_y(matrix):
			return matrix[0].size()
		static func get_max(matrix):
			var x : int = get_x(matrix)
			var y : int = get_y(matrix)
			var m_max = matrix[0][0]
			for row in y:
				for col in x:
					m_max = max(matrix[row][col], m_max);
			return m_max;
		static func get_min(matrix):
			var x : int = get_x(matrix)
			var y : int = get_y(matrix)
			var m_min = matrix[0][0]
			for row in y:
				for col in x:
					m_min = min(matrix[row][col], m_min);
			return m_min;

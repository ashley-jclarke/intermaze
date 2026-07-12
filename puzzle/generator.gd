extends Node

var width = 8
var height = 8
var base = 10
var start_x = 1
var start_y = 1

func generate_new_map(length):
    var map = []
    
    for _y in range(height):
        var row = []
        for _x in range(width):
            row.append(-1)
        map.append(row)
    
    start_x = randi() % (width - 1)
    start_y = randi() % (height - 1)
    
    var cur_x = start_x
    var cur_y = start_y
    
    var step = 0
    map[cur_y % height][cur_x % width] = step
    
    var answer = []
    var prev_direction = -1
    
    for i in range(length):
        # check if row free
        var row_free = false
        for x in range(width):
            if map[cur_y % height][(cur_x + x) % width] == -1:
                row_free = true
                break
        var col_free = false
        for y in range(height):
            if map[(cur_y + y) % height][cur_x % width] == -1:
                col_free = true
                break
        
        var directions = []
        if col_free: directions += [0,2]
        if row_free: directions += [1,3]
        if prev_direction in directions:
            var alternate = 0
            if prev_direction == 0: alternate = 2
            if prev_direction == 1: alternate = 3
            if prev_direction == 3: alternate = 1
            
            directions.erase(alternate)
        
        if len(directions) == 0:
            return generate_new_map(length)
        
        var direction_index = randi() % len(directions)
    
        match directions[direction_index]:
            0: cur_y -= 1
            1: cur_x += 1
            2: cur_y += 1
            3: cur_x -= 1
                
        step += 1
        while map[cur_y % height][cur_x % width] != -1:
            var value = map[cur_y % height][cur_x % width]
            step += value + 1
            match directions[direction_index]:
                0:  cur_y -= 1
                1:  cur_x += 1
                2:  cur_y += 1
                3:  cur_x -= 1
            step %= base
        step %= base
        map[cur_y % height][cur_x % width] = step
        prev_direction = directions[direction_index]
        answer.append(prev_direction)
    return [Vector2(start_x, start_y), map, answer]
                
func print_board(board):
    for y in range(len(board)):
        var row = board[y]
        var rowstr = ""
        for x in range(len(row)):
            var val = row[x]
            if val == -1: rowstr += " "
            else: rowstr += "123456789ABCDE"[val]
        print(rowstr)

func get_value(path):
    var map = []
    for _y in range(height):
        var row = []
        for _x in range(width):
            row.append(-1)
        map.append(row)
    
    var start_x = 0
    var start_y = 0
    var cur_x = start_x
    var cur_y = start_y
    var step = -1
    
    step += 1
    map[cur_y][cur_x] = step
    
    for direction in path:
        match direction:
            0: cur_y -= 1
            1: cur_x += 1
            2: cur_y += 1
            3: cur_x -= 1
                
        step += 1
        while map[cur_y % height][cur_x % width] != -1:
            var value = map[cur_y % height][cur_x % width]
            step += value + 1
            match direction:
                0:  cur_y -= 1
                1:  cur_x += 1
                2:  cur_y += 1
                3:  cur_x -= 1
            step %= base
            #step += 1
        step %= base
        map[cur_y % height][cur_x % width] = step
    return step
    

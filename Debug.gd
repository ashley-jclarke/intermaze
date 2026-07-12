extends Node


var last
var last_count = 0

var frame = " - Frame ==="
var last_frame
var frame_count = 0

func print(text):
    if not multiplayer.is_server(): return
    text = str(text)
    if last_count > 0 and text != last:
        frame += "\n\t" + str(last_count) + " - " + last
        last_count = 0
        last = null
    last = text
    last_count += 1

func _process(_delta):
    pass
    #if frame != last_frame:
        #if last_frame: print(str(frame_count) + last_frame)
        #last_frame = frame
        #frame = " -  Frame ==="
        #frame_count = 0
    #frame_count += 1
    

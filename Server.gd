extends Node

var network = NetworkedMultiplayerENet.new()
var rng = RandomNumberGenerator.new()
var SERVER_PORT = 29500
var MAX_PLAYERS = 20

var world_data = {}

func _ready():
	rng.randomize()
	world_data["character"] = {}
	StartServer()

func _physics_process(delta):
	SendWorldData()

func StartServer():
	network.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = network
	network.connect("peer_connected",self,"_OnPeer_Connected")
	network.connect("peer_disconnected",self,"_OnPeer_Disconnected")

func _OnPeer_Connected(player_id):
	print("Player with peer_id " + str(player_id) + " connected")
	var character_data = {}
	character_data["x"] =  rng.randi_range(100, 400)
	character_data["y"] =  rng.randi_range(100, 400)
	character_data["time"] =  0
	world_data["character"][player_id] = character_data
	rpc_id(0,"SpawnCharacter",character_data,player_id)
	rpc_id(player_id,"InstantiateMissingNodes",world_data)
	
func _OnPeer_Disconnected(player_id):
	print("Player with peer_id " + str(player_id) + " disconnected")
	world_data["character"].erase(player_id)
	rpc_id(0,"DespawnCharacter",player_id)


func SendWorldData():
	rpc_id(0,"ReceiveWorldData",world_data)
	
remote func ReceiveData(data_type,entry):
	var player_id = get_tree().get_rpc_sender_id()
	if world_data[data_type].has(player_id):
		if world_data[data_type][player_id]["time"] > entry["time"]:
			#ignore old packet
			print("ignored packet")
			return
	world_data[data_type][player_id] = entry.duplicate(true)
		
	


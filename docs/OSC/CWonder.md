# CWonder

### Streams

a) cwonder's basic structure can be described as an osc bridge. You can receive from and send to osc streams. The first thing we want to show is how to receive a specific osc stream. You only need to send a "connect command" to cwonder and cwonder will add you as a receiver to this stream. From now on you will receive all the messages that are send to that stream.

    "/WONDER/stream/score/connect", "" 
    "/WONDER/stream/score/connect", "ss", host, port 


If you use the first command (where you do not specify a host and port) the information within the message sent is used. The second command should be used if the address you want to receive the stream on differs from the one you are sending of. Cwonder will reply to the connect messages. The syntax of the reply message is:
/WONDER/reply, "sis", path, error_number, error_message 

If the error_number is not 0 an error occured. The error_message is a text about the status and the action. You can use the error_number to test the result and the error_message for verbose output.
If you connect to the visual stream cwonder will send you in addition to the reply command the xml representation of the currently loaded project. You have to make your osc server to listen to the following command in order to recieve this message ( "/WONDER/project/current", "is", err_num, xmlstring ). err_num will be not 0 if no project is loaded in cwonder.

After you have been connected to a stream cwonder will send you a ping command periodically to see if you are still up and running. cwonder has an internal list of connections and will remove you from that list if you do not reply to the ping commands. Since commands can get lost you are not removed from the list when you do not reply to each ping, a threshold takes care of knowing when a receiver is down. To ping/pong commands have got the following syntax. 

    /WONDER/stream/score/ping", "i", sequence_number
    /WONDER/stream/score/pong", "i", sequence_number

The sequence number is for internal use. Just send the number you received back. You do not need to disconnect from a stream. If you do not send the pong command back you are removed from the list.

There are commands where cwonder needs to change its state. For example cwonder keeps track of the current positions of the sources. The command /WONDER/source/position is processed by cwonder and the information then send to the streams (in this case to the streams: render, visual, score(if recording is enabled) ).  
You can send to a stream directly as well. This message is then only forwarded to a stream without cwonder processing it. One case where this should be used is for replies to actions. If for example the score player is started from the user interface the score player should use the following syntax to reply to this command. 

    "/WONDER/stream/score/send", "ssis", "/WONDER/reply", path, 0, "start to play"

The namespace of the message is /WONDER/stream/score/send. The message the other receivers of this stream will receive is /WONDER/reply in this case which is the first argument of this message. The other arguments just follow like in the other cases. cwonder will then create from the above message the following message and send them to the receivers of the stream score.

    "/WONDER/reply", "sis" path, 0, "start to play"

b) In the current release 4 streams are implemented where you can connect to and receive from. OSC messages have to use the following pathes to use the streams. 

    "/WONDER/stream/render
	"/WONDER/stream/score
	"/WONDER/stream/visual
	"/WONDER/stream/timer

Most users (like UI, visualisers) will connect to the stream visual. Whenever there is a change in the sources (position, angle, type) or a new scene is selected the receivers of the visual stream will get the OSC messsages as well. When you connect to such a stream cwonder will send you the current state of the scene. 
The render stream has the difference that the timing information in such a message (timestamp, duration) is converted to "inner wonder time" by cwonder.
cwonder does the timestamping for the messages when a score gets recorded. When cwonder gets the record message it will use the current time to generate the timestamps and will stamp the messages like position, angle etc with these stamps. This is why there is a score stream to which you can connect as well and from which you will receive the messages with the correct timestamps.

### Scenes
All the commands below will send a reply command to the address the command is received from. The reply command has got the following form: /WONDER/reply, "sis", path, error_number, error_message. If there has been no error occured the error_number will be zero. 

    "/WONDER/project/load", "ss", projectname, path

In addition to the reply command the cwonder will send the calling application the xml representation of the currently loaded project. You have to make your osc server to listen to the following command in order to receive this message ( "/WONDER/project/current", "is", err_num, xmlstring ). err_num will be non 0 if no project is loaded in cwonder.

    "/WONDER/project/create", "ss", projectname, path
    "/WONDER/project/save", "ss", projectname, path

    "/WONDER/scene/select", "if", id, duration 
    "/WONDER/scene/set", "i", id
    "/WONDER/scene/add", "i", id
    "/WONDER/scene/remove", "i", id
    "/WONDER/scene/copy", "ii", sourceid, targetid 
    "/WONDER/scene/name", "is", id, name

These affect the current selected scene.

    "/WONDER/scene/source/name", "is", srcid, name   (enable srcid)	
    "/WONDER/scene/source/enable", "ii", srcid, 1   (enable srcid)	
    "/WONDER/scene/source/enable", "ii", srcid, 0   (disable srcid)
    "/WONDER/scene/source/enable", "ii", -1, 1   (enable all)
    "/WONDER/scene/source/enable", "ii", -1, 0   (disable all)


### Position, Angle and Friends

To control the sources you will need the following commands.

	"/WONDER/source/position", "ifffff", srcid, x, y, z, timestamp, duration
	"/WONDER/source/positionxy", "iff", srcid, x, y

This command is used to control the position of a source by a mobile phone connected to a laptop over bluetooth. For simplicity the z coordinate was not provided as argument. Since the commands must be processed directly the timestamp and duration arguments were set by cwonder to an appropriate value.	

	"/WONDER/source/type", "iiff", srcid, type, angle, timestamp
	"/WONDER/source/angle", "ifff", srcid, angle, timestamp, duration 
    "/WONDER/source/mute", "ii", srcid, mute
	mute=1 the source is muted, mute=0 the source is unmuted
	"/WONDER/source/fadejump_threshold", "ii", srcid, threshold 



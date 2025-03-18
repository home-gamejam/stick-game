# Signaling Server - WebSockets

- lobby host button clicked
- client: connect_to_server() called, peer created, lobby and peer id both set to 0, ws connects to server
- server: poll() picks up on available client connection, creates peer, sends CONNECTED msg back to client
- client: poll() picks up CONNECTED msg, sets peer id from the message, sends HOST or JOIN msg back to server for the peer based on whether lobby_id is known or not, emits connected event which causes mesh to be initialized for the current peer.

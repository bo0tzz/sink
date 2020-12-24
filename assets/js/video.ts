import {Socket} from "phoenix"
import { v4 as uuidv4 } from "uuid";

function init() {

    let socket = new Socket("/socket", {params: {}})
    let id = uuidv4();
    // Finally, connect to the socket:
    socket.connect()

    // Now that you are connected, you can join channels with a topic:
    let channel = socket.channel("video:foo", {id})

    let send = (event: string, data = {}) => {
        data = {
            ...data,
            id
        }
        channel.push(event, data)
    }

    let player = document.querySelector<HTMLVideoElement>("#video-player")!;

    player.addEventListener("pause", _event => {
        // console.log("sending pause");
        send("pause");
    })

    player.addEventListener("play", _event => {
        // console.log("sending play");
        send("play")
    })

    channel.on("ping", ping => {
        console.log("Received ping", ping);
        let pong = {
            ...ping,
            clientTime: new Date().getTime()
        }
        send("pong", pong)
    })

    channel.on("pause", _payload => {
        console.log("receiving pause");
        player.pause();
    })

    channel.on("play", _payload => {
        console.log("receiving play");
        player.play();
    })

    channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

}

export {init} 
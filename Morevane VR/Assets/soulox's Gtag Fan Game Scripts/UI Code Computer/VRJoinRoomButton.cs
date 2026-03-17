using UnityEngine;
using Photon.Pun;
using Photon.Realtime;

public class UIJoinRoomButton : MonoBehaviourPunCallbacks
{
    public CodeManager codeManager;

    private string roomToJoin = "";
    private bool joinRequested = false;

    private void Start()
    {
        if (!PhotonNetwork.IsConnected)
        {
            Debug.Log("Connecting to Photon...");
            PhotonNetwork.ConnectUsingSettings();
        }
    }

    // Hook this to Button -> OnClick()
    public void OnJoinPressed()
    {
        string code = codeManager.NewRoomThingy;

        if (string.IsNullOrEmpty(code))
        {
            Debug.LogWarning("No room code entered!");
            return;
        }

        roomToJoin = code;
        joinRequested = true;

        Debug.Log("Join requested for room: " + roomToJoin);

        if (PhotonNetwork.InRoom)
        {
            Debug.Log("Already in a room → leaving...");
            PhotonNetwork.LeaveRoom();
        }
        else
        {
            TryJoinRoom();
        }
    }

    public override void OnConnectedToMaster()
    {
        Debug.Log("Connected to Master → Joining Lobby...");
        PhotonNetwork.AutomaticallySyncScene = true;
        PhotonNetwork.JoinLobby();
    }

    public override void OnJoinedLobby()
    {
        Debug.Log("In Lobby!");

        if (joinRequested)
            TryJoinRoom();
    }

    public override void OnLeftRoom()
    {
        Debug.Log("Left room → Rejoining lobby...");
        PhotonNetwork.JoinLobby();
    }

    private void TryJoinRoom()
    {
        if (!PhotonNetwork.IsConnectedAndReady || !PhotonNetwork.InLobby)
        {
            Debug.Log("Not ready to join room yet...");
            return;
        }

        if (string.IsNullOrEmpty(roomToJoin))
            return;

        RoomOptions options = new RoomOptions
        {
            MaxPlayers = 10,
            IsVisible = false,
            IsOpen = true
        };

        Debug.Log("Joining room: " + roomToJoin);

        PhotonNetwork.JoinOrCreateRoom(
            roomToJoin,
            options,
            TypedLobby.Default
        );
    }
}

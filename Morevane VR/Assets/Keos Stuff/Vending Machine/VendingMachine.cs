using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(PhotonView))]
public class VendingMachine : MonoBehaviour, IPunObservable
{
    public string HandTag;
    public GameObject ItemToDrop;
    public float CoolDown;
    public Transform SpawnPoint;
    public Vector3 StartVelocity;

    PhotonView PTView;
    bool CanPress = true;
    List<GameObject> NotConnectedSpawnedObj;

    private void Start()
    {
        PTView = GetComponent<PhotonView>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(HandTag) && CanPress && PhotonNetwork.IsConnected)
        {
            StartCoroutine(CoolDownFunktion());
            PTView.RPC(nameof(SpawnItem), RpcTarget.AllBuffered);
        }
    }

    [PunRPC]
    public void SpawnItem()
    {
        GameObject item = Instantiate(ItemToDrop, SpawnPoint.position, SpawnPoint.rotation);
        Rigidbody itemrb = item.GetComponent<Rigidbody>();
        itemrb.velocity = StartVelocity;
    }

    private IEnumerator CoolDownFunktion()
    {
        CanPress = false;
        yield return new WaitForSeconds(CoolDown);
        CanPress = true;
    }
    
    public void OnPhotonSerializeView(PhotonStream idk, PhotonMessageInfo sdf)
    {
        //Sync funktions
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(VendingMachine))]
public class VendingMachineEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.DrawDefaultInspector();

        VendingMachine script = (VendingMachine)target;
        if (GUILayout.Button("Button Press"))
        {
            if (Application.isPlaying)
            {
                PhotonView PTView = script.GetComponent<PhotonView>();
                PTView.RPC(nameof(script.SpawnItem), RpcTarget.AllBuffered);
            }
            else
            {
                return;
            }
        }
    }
}
#endif

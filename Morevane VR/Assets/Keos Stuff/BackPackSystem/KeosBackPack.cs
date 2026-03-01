using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using UnityEngine.Events;
using Photon.Pun;

public class KeosBackPack : MonoBehaviourPunCallbacks
{
    public bool IsOpen = false;

    [Header("Main Settings")]
    public string PickUpTag = "PickUpAble";
    public float DropSpeed;
    public float DropTreshHold;
    public Transform DropPoint;
    public Angles Rotations;

    [System.Flags]
    public enum Angles
    {
        None = 0,
        X = 1,
        Y = 2,
        Z = 4
    }

    [Header("Events")]
    public UnityEvent OnOpen;
    public UnityEvent OnClose;

    [Header("Editor")]
    public List<GameObject> Items;

    bool CanDrop = true;
    bool LastState = false;

    private void Update()
    {
        //Last state it was open, now we closed it...
        if (LastState == true &! IsOpen)
        {
            if (OnClose != null)
            {
                OnClose.Invoke();
            }
        }
        //Last state it was closed now its open
        if (LastState == false && IsOpen) 
        { 
            if (OnOpen != null)
            {
                OnOpen.Invoke();
            }
        }
        LastState = IsOpen;

        if (!IsOpen)
            return;


        if (CheckRot() && CanDrop)
        {
            foreach (GameObject g in Items)
            {
                g.transform.position = DropPoint.position;
                g.SetActive(true);
                Items.Remove(g);
                StartCoroutine(CoolDownFunktion());
            }
        }
    }

    public IEnumerator CoolDownFunktion()
    {
        CanDrop = false;
        yield return new WaitForSeconds(DropSpeed);
        CanDrop = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!IsOpen)
            return;

        if (!CheckRot() && other.CompareTag(PickUpTag))
        {
            //That the one thats synced but i think you dont need that
            //photonView.RPC(nameof(PickUpItem), RpcTarget.AllBuffered, other.gameObject.GetComponent<PhotonView>());
            Items.Add(other.gameObject);
            other.gameObject.SetActive(false);
        }
    }

    [PunRPC]
    public void PickUpItem(int itemID)
    {
        GameObject item = PhotonView.Find(itemID).gameObject;

        if (item != null)
        {
            Items.Add(item);
            item.SetActive(false);
        }
    }

    bool CheckRot()
    {
        float xRot = NormalizeAngle(transform.rotation.eulerAngles.x);
        float yRot = NormalizeAngle(transform.rotation.eulerAngles.y);
        float zRot = NormalizeAngle(transform.rotation.eulerAngles.z);

        if (Rotations.HasFlag(Angles.X) && Mathf.Abs(xRot) > DropTreshHold)
            return true;

        if (Rotations.HasFlag(Angles.Y) && Mathf.Abs(yRot) > DropTreshHold)
            return true;

        if (Rotations.HasFlag(Angles.Z) && Mathf.Abs(zRot) > DropTreshHold)
            return true;

        return false;
    }

    float NormalizeAngle(float angle)
    {
        return (angle > 180) ? angle - 360 : angle;
    }
}

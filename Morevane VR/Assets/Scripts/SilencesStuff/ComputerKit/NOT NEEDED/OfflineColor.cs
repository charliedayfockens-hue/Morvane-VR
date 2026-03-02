using Photon.VR;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OfflineColor : MonoBehaviour
{
    public PhotonVRManager pvm;
    public List<Renderer> ColoredRenders;

    private void Update()
    {
        foreach (Renderer r in ColoredRenders)
        {
            r.material.color = pvm.Colour;
        }
    }
}

using UnityEngine;

public class PLAYFABSellButton : MonoBehaviour
{
    public string HandTag = "HandTag";
    public PLAYFABSellingManager Manager;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(HandTag))
        {
            Manager.SellItems();
        }
    }
}

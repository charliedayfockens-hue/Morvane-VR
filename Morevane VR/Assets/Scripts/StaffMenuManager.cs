using UnityEngine;

public class StaffMenuManager : MonoBehaviour
{
    public GameObject menuPrefab;
    public Transform playerHead;

    [Header("TEST IN UNITY")]
    public bool spawnMenu;

    private GameObject currentMenu;

    void Update()
    {
        // Spawn menu if enabled
        if (spawnMenu && currentMenu == null)
        {
            Vector3 spawnPos = playerHead.position + playerHead.forward * 1f;
            Quaternion spawnRot = Quaternion.LookRotation(playerHead.forward);

            currentMenu = Instantiate(menuPrefab, spawnPos, spawnRot);
        }

        // Despawn menu if disabled
        if (!spawnMenu && currentMenu != null)
        {
            Destroy(currentMenu);
        }
    }
}
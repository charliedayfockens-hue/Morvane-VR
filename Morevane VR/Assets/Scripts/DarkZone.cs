using UnityEngine;

public class DarkZone : MonoBehaviour
{
    public float darkIntensity = 0.2f;
    private float originalIntensity;

    void Start()
    {
        originalIntensity = RenderSettings.ambientIntensity;
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            RenderSettings.ambientIntensity = darkIntensity;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            RenderSettings.ambientIntensity = originalIntensity;
        }
    }
}
using System.Collections.Generic;
using UnityEngine;

public class BallTest : MonoBehaviour
{
    [Header("Made by Keo.CS")]
    [Header("No need for credits ;)")]
    [Header("I hope thats how you spell it")]
    public float Multiplyer = 1f;
    public AudioClip[] HitSound;
    public AudioClip[] CollsionSound;
    public bool UseLimit;
    public float Limit;
    [Header("DONT USE IF YOU DO NOT \n KNOW WHAT YOU ARE DOING")]
    public bool OnTriggerStayVel;
    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("LOL");
        if (other.GetComponent<NonRBVelocity>() != null)
        {
            Rigidbody rb = GetComponent<Rigidbody>();
            if (UseLimit)
            {
                Vector3 Speed = rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
                if (Speed.y > Limit)
                {
                    Speed.y = Limit;
                }
                if (Speed.x > Limit)
                {
                    Speed.x = Limit;
                }
                if (Speed.z > Limit)
                {
                    Speed.z = Limit;
                }
                rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
            }
            else
            {
                rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
            }
            if (GetComponent<AudioSource>() != null)
            {
                DoSounds(HitSound);
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (OnTriggerStayVel && other.GetComponent<NonRBVelocity>() != null)
        {
            Rigidbody rb = GetComponent<Rigidbody>();
            if (UseLimit)
            {
                Vector3 Speed = rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
                if (Speed.y > Limit)
                {
                    Speed.y = Limit;
                }
                if (Speed.x > Limit)
                {
                    Speed.x = Limit;
                }
                if (Speed.z > Limit)
                {
                    Speed.z = Limit;
                }
                rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
            }
            else
            {
                rb.velocity += other.GetComponent<NonRBVelocity>().Velocity * Multiplyer;
            }
            if (GetComponent<AudioSource>() != null)
            {
                DoSounds(HitSound);
            }
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<AudioSource>() != null)
        {
            DoSounds(HitSound);
        }
    }

    public void DoSounds(AudioClip[] List)
    {
        if (List.Length != 0) 
        {
            int RIDX = Random.Range(0, List.Length);
            GetComponent<AudioSource>().clip = List[RIDX];
            GetComponent<AudioSource>().Play();
        }
    }
}

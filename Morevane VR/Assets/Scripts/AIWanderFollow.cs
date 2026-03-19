using UnityEngine;
using UnityEngine.AI;

public class AIWanderFollow : MonoBehaviour
{
    public string targetTag;
    public float followDistance = 5f;
    public AudioClip followSound;
    public Transform[] points;
    public AudioSource audioSource;
    public float patrolSpeed = 3.5f;
    public float followSpeed = 5f;
    public float minimumSpeedRequired = 2.0f;

    private NavMeshAgent agent;
    private bool isFollowing = false;
    private Transform currentTarget;
    private int destPoint = 0;
    private Vector3 previousPosition;
    private float currentSpeed;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        audioSource.clip = followSound;
        audioSource.loop = true;
        agent.autoBraking = false;
        agent.speed = patrolSpeed;
        GotoNextPoint();
    }

    void Update()
    {
        FindClosestTargetWithTag(targetTag);

        if (currentTarget != null && currentTarget.CompareTag(targetTag))
        {
            float distanceToTarget = Vector3.Distance(currentTarget.position, transform.position);
            currentSpeed = (currentTarget.position - previousPosition).magnitude / Time.deltaTime;
            previousPosition = currentTarget.position;

            if (distanceToTarget <= followDistance && currentSpeed >= minimumSpeedRequired)
            {
                agent.SetDestination(currentTarget.position);
                agent.speed = followSpeed;

                if (!isFollowing)
                {
                    isFollowing = true;
                    audioSource.Play();
                }
            }
            else
            {
                StopFollowingAndPatrol();
            }
        }
        else
        {
            StopFollowingAndPatrol();
        }
    }

    void FindClosestTargetWithTag(string tag)
    {
        GameObject[] targets = GameObject.FindGameObjectsWithTag(tag);
        float closestDistance = Mathf.Infinity;
        Transform closestTarget = null;

        foreach (GameObject target in targets)
        {
            float distance = Vector3.Distance(target.transform.position, transform.position);

            if (distance < closestDistance)
            {
                closestDistance = distance;
                closestTarget = target.transform;
            }
        }

        currentTarget = closestTarget;
    }

    void StopFollowingAndPatrol()
    {
        if (isFollowing)
        {
            isFollowing = false;
            audioSource.Stop();
            agent.speed = patrolSpeed;
        }

        if (!agent.pathPending && agent.remainingDistance < 0.5f)
        {
            GotoNextPoint();
        }
    }

    void GotoNextPoint()
    {
        if (points.Length == 0)
            return;

        agent.destination = points[destPoint].position;
        destPoint = (destPoint + 1) % points.Length;
    }
}

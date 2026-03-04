using UnityEngine;

public class OpenVent : MonoBehaviour
{
	public Transform doort;

	public Vector3 open;

	public Vector3 close;

	public bool ifNotWhatItSeems;

	public bool ifInHorror;

	[Range(0f, 1f)]
	public float interp;

	public bool isopen;

	public float doorspeed;

	public AudioSource move;

	public AudioClip moveSound;

	private bool sound = true;

	private void Update()
	{
		doort.localPosition = Vector3.Lerp(close, open, interp);
		if (isopen)
		{
			if (interp < 1f)
			{
				interp += Time.deltaTime * doorspeed;
				if (sound)
				{
					move.PlayOneShot(moveSound);
					sound = false;
				}
			}
			else
			{
				sound = true;
			}
		}
		else if ((double)interp > 0.01)
		{
			interp -= Time.deltaTime * doorspeed;
			if (sound)
			{
				move.PlayOneShot(moveSound);
				sound = false;
			}
		}
		else
		{
			sound = true;
		}
	}

	public void OnTriggerEnter(Collider other)
	{
		if (other.gameObject.tag == "Player")
		{
			opendoor();
			if (ifNotWhatItSeems)
			{
				doorspeed = 20f;
			}
			if (ifInHorror)
			{
				doorspeed = 0.05f;
			}
			else
			{
				doorspeed = 1.25f;
			}
		}
	}

	public void OnTriggerExit(Collider other)
	{
		if (other.gameObject.tag == "Player")
		{
			closedoor();
			if (ifNotWhatItSeems)
			{
				doorspeed = 20f;
			}
			if (ifInHorror)
			{
				doorspeed = 0.05f;
			}
			else
			{
				doorspeed = 1.25f;
			}
		}
	}

	public void opendoor()
	{
		isopen = true;
	}

	public void closedoor()
	{
		isopen = false;
	}
}

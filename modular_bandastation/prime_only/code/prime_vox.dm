/datum/singleton/sound_effect/centcom_vox
	suffix = "_centcom_vox_v1"
	ffmpeg_arguments = "highpass=f=200,lowpass=f=3800,equalizer=f=650:t=q:w=1.5:g=6,acompressor=threshold=0.12:ratio=5:makeup=2,volume=2,asoftclip=type=tanh:threshold=0.7,acrusher=bits=6:mix=0.25:mode=lin:aa=1:samples=2,aecho=0.9:0.85:6|14:0.25|0.18,alimiter=limit=0.95:level=false"

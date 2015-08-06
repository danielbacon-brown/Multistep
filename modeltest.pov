// -w320 -h240

#version 3.6;

#include "colors.inc"
#include "textures.inc"
#include "shapes.inc"

global_settings {max_trace_level 5 assumed_gamma 1.0}

camera {
	location <-1.531328, 3.062656, -4.593984>
	direction <0, 0,  2.25>
	right x*1.33
	look_at <0,0,0>
}

#declare Dist=80.0;
light_source {< -25, 50, -50> color White
	fade_distance Dist fade_power 2
}
light_source {< 50, 10,  -4> color Gray30
	fade_distance Dist fade_power 2
}
light_source {< 0, 100,  0> color Gray30
	fade_distance Dist fade_power 2
}

sky_sphere {
	pigment {
		gradient y
		color_map {
			[0, 1  color White color White]
		}
	}
}

#declare Xaxis = union{
	cylinder{
		<0,0,0>,<0.8,0,0>,0.05
	}
	cone{
		<0.8,0,0>, 0.1, <1,0,0>, 0
	}
	texture { pigment { color Red } }
}
#declare Yaxis = union{
	cylinder{
		<0,0,0>,<0,0.8,0>,0.05
	}
	cone{
		<0,0.8,0>, 0.1, <0,1,0>, 0
	}
	texture { pigment { color Green } }
}
#declare Zaxis = union{
	cylinder{
	<0,0,0>,<0,0,0.8>,0.05
	}
	cone{
		<0,0,0.8>, 0.1, <0,0,1>, 0
	}
	texture { pigment { color Blue } }
}
#declare Axes = union{
	object { Xaxis }
	object { Yaxis }
	object { Zaxis }
}
#declare Material_Vacuum = texture{ pigment{ color transmit 1.0 } }
#declare Material_SU8 = texture{ pigment{ rgb <0.377880,0.008911,0.004669> } }
#declare Layer_Front = union{
/*
	difference{
		intersection{
			plane{ <0.510443,0.000000,0>, 0.255221 }
			plane{ <-0.510443,-0.000000,0>, 0.255221 }
			plane{ <0.000000,0.510443,0>, 0.255221 }
			plane{ <-0.000000,-0.510443,0>, 0.255221 }
			plane{ <0.510443,0.510443,0>, 0.360938 }
			plane{ <-0.510443,-0.510443,0>, 0.360938 }
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 0.000000 }
		}
// nshapes = 0
		texture { Material_Vacuum }
	}
*/
	translate +z*0.000000
}
#declare Layer_Grating1 = union{
/*
	difference{
		intersection{
			plane{ <0.510443,0.000000,0>, 0.255221 }
			plane{ <-0.510443,-0.000000,0>, 0.255221 }
			plane{ <0.000000,0.510443,0>, 0.255221 }
			plane{ <-0.000000,-0.510443,0>, 0.255221 }
			plane{ <0.510443,0.510443,0>, 0.360938 }
			plane{ <-0.510443,-0.510443,0>, 0.360938 }
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
// nshapes = 7
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.115106
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.115106
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.286230
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.115106
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.115106
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.037100
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.379348
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.286230
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.035833
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.474610
	translate +y*0.286230
}
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.037100
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.379348
}
		texture { Material_Vacuum }
	}
*/
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.115106
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.115106
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.286230
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.115106
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.115106
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.111826
	scale +y*0.037100
	rotate +z*0.000000
	translate +x*0.111826
	translate +y*0.379348
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.286230
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.035833
	scale +y*0.056017
	rotate +z*0.000000
	translate +x*0.474610
	translate +y*0.286230
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	difference{
		intersection{
box{
	<-1,-1,0>, <1,1,1.000000>
	scale +x*0.038441
	scale +y*0.037100
	rotate +z*0.000000
	translate +x*0.262092
	translate +y*0.379348
}
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 1.000000 }
		}
		texture { Material_SU8 }
	}
	translate +z*0.000000
}
#declare Layer_Interference = union{
	difference{
		intersection{
			plane{ <0.510443,0.000000,0>, 0.255221 }
			plane{ <-0.510443,-0.000000,0>, 0.255221 }
			plane{ <0.000000,0.510443,0>, 0.255221 }
			plane{ <-0.000000,-0.510443,0>, 0.255221 }
			plane{ <0.510443,0.510443,0>, 0.360938 }
			plane{ <-0.510443,-0.510443,0>, 0.360938 }
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 3.000000 }
		}
// nshapes = 0
		texture { Material_SU8 }
	}
	translate +z*1.000000
}
#declare Layer_Back = union{
	difference{
		intersection{
			plane{ <0.510443,0.000000,0>, 0.255221 }
			plane{ <-0.510443,-0.000000,0>, 0.255221 }
			plane{ <0.000000,0.510443,0>, 0.255221 }
			plane{ <-0.000000,-0.510443,0>, 0.255221 }
			plane{ <0.510443,0.510443,0>, 0.360938 }
			plane{ <-0.510443,-0.510443,0>, 0.360938 }
			plane{ <0,0,-1>, 0 }
			plane{ <0,0,1>, 0.000000 }
		}
// nshapes = 0
		texture { Material_SU8 }
	}
	translate +z*4.000000
}
#declare Layers = union {
	//object{ Layer_Front }
	object{ Layer_Grating1 }
	object{ Layer_Interference }
	//object{ Layer_Back }
}

Axes
Layers

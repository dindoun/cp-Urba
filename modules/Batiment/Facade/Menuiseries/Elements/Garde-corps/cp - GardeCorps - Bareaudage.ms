

plugin simpleObject		cp_gardeCorps_bareaudage
name:"Bareaudage"
classID:#(0x34bbcca7, 0x35e10b2b)
category:"CP | Menuiserie	| Element | Garde Corps"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_gardeCorps_bareaudage"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 		type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		nom	 					type:#string 			default:"Garde-corps Bareaudage"
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ mat ID ----------
-- 		low_poly					type:#boolean 		ui:shk_lowPoly				default:false
		matId					type:#integer 			ui:spn_matId				default:1
		
		qualite					type:#integer 			ui:rdo_qualite				default:1
		
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Param�tres"
	(
		spinner spn_longueur 			"longueur" 			type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
	)
	rollout roll_divers  "Divers" (
		/* group "Qualit�" (
			checkbox	shk_lowPoly		"Low poly"
		) */
		group "Qualit�" (
			radioButtons rdo_qualite 		"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId			 	"Menuiseries" 			type:#integer range:[1,1000,1]
		)
		
	) ---- fin rollout	----------
	
	
	

	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		
		--- Construction ---------------------------------------------------------------------------------------
-- 		local composant=	if low_poly 	then	 createInstance  cp_prim_boiteU		matId:matId
-- 													else	 createInstance  cp_prim_boite		matId:matId
		/* 
		local composant
		case qualite	of (
			1:	composant	=	 createInstance  cp_prim_boite				matId:matId
			2:	composant	=	 createInstance  cp_prim_boiteU				matId:matId
			3:	composant	=	 createInstance  cp_prim_planVertical		matId:matId
		)
		 
		
		composant.longueur			=	longueur
		composant.hauteur			=	hauteur
		if qualite != 3  do
			composant.profondeur		=	profondeur
		
		mgr_mesh.attacher		mesh		composant
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		 */
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
			)		
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------











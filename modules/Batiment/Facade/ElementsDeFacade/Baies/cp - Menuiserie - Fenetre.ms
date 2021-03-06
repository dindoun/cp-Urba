

plugin simpleObject		cp_menuiserie_fenetre
name:"Fen�tre"
classID:#(0x58b7dcde, 0x439ca73a)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuiserie_fenetre"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Pr�d�finitions ------------------
	local corriger_parametres
	
	----- les composants -----------	
	local	compo_ouvrant_1, compo_ouvrant_2
	local compo_cadre
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_dimensions rollout:rol_global	(
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		menuis_profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:5.
		
		cadre						type:#boolean 		ui:shk_cadre				default:true
		menuis_epaisseur		type:#worldUnits 	ui:spn_cadre_ep			default:5.
	)
	parameters params_general rollout:roll_parametres	(
		
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		
		----- les menuiseries -----------
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		----- ouvrants ---------------------
		ouvrant_profondeur	 		type:#worldUnits 	default:4.	
		ouvrant_callage	 			type:#worldUnits 	default:1.5
		ouvrant_cadre_larg		 	type:#worldUnits 	ui:spn_ouvrant_cadre_larg				default:4.	
		div_profondeur	 			type:#worldUnits 	default:3.
		
		ouvrant_double				type:#boolean 		ui:shk_double					default:false
		ouvrant_tierce_pourcent	type:#float		 		ui:spn_tierce_pourcent		default:50.
		
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:2.
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr		default:0.
		div_montants_nbr_2		 	type:#integer		 	ui:spn_div_montants_nbr_2	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr		default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti			default:0.
		
		symetrie							type:#boolean 		ui:shk_symetrie				default:false
		ouvert_angle_1				type:#float 		/* 	ui:spn_angle_1	 */			default:0.
		ouvert_angle_2				type:#float 		/* 	ui:spn_angle_2	 */			default:0.
		
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Fen�tre"
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		est_ouvrable					type:#boolean 					default:true
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	parameters params_hasard --rollout:roll_hasard
	(
		hasard_seed					type:#integer 		/* 	ui:spn_hasard_seed	 */	default:123456
		
		fen_proba_ouv				type:#float 		/* 	ui:spn_fen_proba_ouv	 */	default:0.
		fen_ouvMax					type:#float 		/* 	ui:spn_fen_ouvMax	 */		default:0.
	)
	
	
	
	
	
	
	
	
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur 		"menuis_profondeur" 			type:#worldunits 	range:[0,1e20,0]
		group "cadre" (
			checkbox	shk_cadre				"Cadre"
			spinner 	spn_cadre_ep 			"Epaisseur" 			type:#worldunits 	range:[0,1e20,0]
		)
	)
	rollout roll_parametres  "Fen�tre"	(
		
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_ouvrant_cadre_larg	 	"Menuis. larg." 		type:#worldunits range:[0,1e20,0]
		checkbox	shk_double							"double"		
		checkbox	shk_symetrie						"Inverser sens ouv."			
		spinner 	spn_tierce_pourcent 			"Tierc�e (%)" 		type:#float				range:[0,100,0]
		
		group "Divisions" (	
			spinner		spn_div_largeur			 	"Largeur" 			type:#worldunits		range:[0,1e20,0]
			spinner 	spn_div_montants_nbr	 	"Montants 1" 		type:#integer			range:[0,1e20,0]
			spinner 	spn_div_montants_nbr_2	 "Montants 2" 		type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 	"Traverses" 		type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 		"Align. vert." 		type:#worldunits		range:[-1e20,1e20,0]
		)
		
		
		fn actualiser =(
			shk_symetrie.enabled = not ouvrant_double
			if ouvrant_double do shk_symetrie.triState 	= 2
			
			spn_tierce_pourcent.indeterminate				=	not ouvrant_double
			spn_tierce_pourcent.enabled 						=	ouvrant_double 
			
			spn_div_montants_nbr_2.indeterminate		=	not ouvrant_double 
			spn_div_montants_nbr_2.enabled 				=	ouvrant_double
		)
		on roll_parametres	open 					do actualiser ()
		on shk_double 		changed state 	do actualiser ()
		on shk_tierce	 		changed state 	do actualiser ()
	)
	rollout roll_divers  "Divers"	(
		group "Qualit�" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	
	
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
	)
	fn get_longueur	=	longueur
	
	
	
	
	---- les composants ---------------------
	fn composants_actualiser	= with redraw off (
		
		---- creation des composants ------------------
		if compo_ouvrant_1 	== undefined	do	compo_ouvrant_1	= 	createInstance  cp_menuisElem_chassisVitre				
		if compo_ouvrant_2 	== undefined	do	compo_ouvrant_2	= 	createInstance  cp_menuisElem_chassisVitre	
		if cadre and compo_cadre 	== undefined	do	compo_cadre		= createInstance  	cp_menuisElem_cadre
		
		
		---- maj ouvrant		----
		compo_ouvrant_1.profondeur 				= menuis_profondeur /2
		compo_ouvrant_1.hauteur						=	if cadre then hauteur  - menuis_epaisseur*2 else hauteur
		compo_ouvrant_1.cadre_largeur 			= ouvrant_cadre_larg
		compo_ouvrant_1.travBasse_hauteur		= ouvrant_cadre_larg		
		
		compo_ouvrant_1.div_montants_nbr 		= div_montants_nbr
		compo_ouvrant_1.div_traverses_nbr 		= div_traverses_nbr
		compo_ouvrant_1.div_largeur					= div_largeur
		compo_ouvrant_1.div_profondeur			= menuis_profondeur /2
		compo_ouvrant_1.div_calage_verti			= div_calage_verti
		compo_ouvrant_1.vitrage_epaisseur		= vitrage_epaisseur
		
		compo_ouvrant_1.qualite				 		= qualite
		compo_ouvrant_1.matId_menuis	 		= matId_menuis
		compo_ouvrant_1.matId_vitrage	 		= matId_vitrage		
	
		if not ouvrant_double then (
			compo_ouvrant_1.longueur				=	if cadre then longueur - menuis_epaisseur*2 else longueur
		) else (
			compo_ouvrant_1.longueur				=	if cadre then (longueur 	*  ouvrant_tierce_pourcent / 100 ) - menuis_epaisseur else (longueur 	*  ouvrant_tierce_pourcent / 100 )
			
			compo_ouvrant_2 								= copy compo_ouvrant_1
			compo_ouvrant_2.longueur 				=  if cadre then ( longueur	* ( 100 - ouvrant_tierce_pourcent ) / 100 ) - menuis_epaisseur else	( longueur	* ( 100 - ouvrant_tierce_pourcent ) / 100 ) 
			compo_ouvrant_2.div_montants_nbr 	=  div_montants_nbr_2
			
		)
		
		
		
		
		
		
		
		--- hasard	---------------
		local est_ouverte =   ( random 0.  100. ) < fen_proba_ouv 
		if est_ouverte 	then (
			ouvert_angle_1 = random 0.		fen_ouvMax
			ouvert_angle_2 = random 0.		fen_ouvMax		
		)
		
		
		-----	le cadre 	-------------
		if cadre do	(
			compo_cadre.longueur						=	longueur
			compo_cadre.hauteur							=	hauteur
			compo_cadre.profondeur					=	menuis_profondeur
			compo_cadre.menuis_epaisseur			=	menuis_epaisseur
			compo_cadre.travBasse						=	true
			compo_cadre.travBasse_hauteur			=	menuis_epaisseur
			
			compo_cadre.qualite			 				= qualite		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		composants_actualiser ()
		
		--- vider le mesh --------
		delete mesh
		
		
		----Donn�es ------------	
		local origine_ouv_1, rotate_ouv_1, recalle_ouv_1		
		local origine_ouv_2, rotate_ouv_2, recalle_ouv_2
		
		
		local longueur_ouvrant 		= 	compo_ouvrant_1.longueur 
		local callage_montant_G 	= 	0
		local callage_montant_D 	=	callage_montant_G
		local ouvrant_pos_z 			= 	callage_montant_G
		local profondeur_temp		=	menuis_profondeur
		local ouvrant_callage_y		= 	if qualite != 3 	then	profondeur_temp	else 0
		
		
		local recalage_X = if cadre 			then menuis_epaisseur else 0
		local recalage_Y = if qualite != 3	then menuis_profondeur / 2 else 0
		local recalage_Z = if cadre 			then menuis_epaisseur else 0
		
		
		
		if  symetrie and not ouvrant_double	then (
			if qualite != 3	then 
				origine_ouv_1	=	transMatrix	[ -longueur_ouvrant, - menuis_profondeur / 2 ,	ouvrant_pos_z ]	
			else
				origine_ouv_1	=	transMatrix	[ -longueur_ouvrant, 0 ,	ouvrant_pos_z ]	
			rotate_ouv_1			=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1		=	transMatrix	[longueur - callage_montant_G - recalage_X , ouvrant_callage_y  ,	recalage_Z ]
			
			
		) else (
			if qualite != 3	then 
				origine_ouv_1	=	transMatrix	[ 0, - menuis_profondeur / 2  ,	ouvrant_pos_z ]
			else
				origine_ouv_1	=	transMatrix	[ 0, 0,	ouvrant_pos_z ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix		[callage_montant_G + recalage_X , ouvrant_callage_y ,	recalage_Z ]
		)
		
		
		
		
		if  ouvrant_double do (
			if qualite != 3	then 
				origine_ouv_2	=	transMatrix	[ -compo_ouvrant_2.longueur, - menuis_profondeur / 2 ,	ouvrant_pos_z ]
			else
				origine_ouv_2	=	transMatrix	[ -compo_ouvrant_2.longueur, 0,	ouvrant_pos_z ]
			rotate_ouv_2 		=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2		=	transMatrix	[longueur - callage_montant_D - recalage_X , ouvrant_callage_y ,	recalage_Z ]
		)
		
		
		
		
		
		
		
		
		
		---- le cadre -------
		if cadre do	
			mgr_mesh.attacher		mesh		compo_cadre
		
		---- 1er ouvrant ------------
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1
		mgr_mesh.attacher		mesh		compo_ouvrant_1 	transf:transf_ouvrant_1
		
		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2		
			mgr_mesh.attacher		mesh		compo_ouvrant_2 	transf:transf_ouvrant_2
			
		)
		
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
				1: (
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
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
					
					pt_hauteur				=	gridPoint
					
				)
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
					
			)		
	) --- fin tool create ---------
	
) ------- fin plugin ---------------------






		



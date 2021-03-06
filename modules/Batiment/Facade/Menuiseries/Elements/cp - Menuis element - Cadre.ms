
plugin simpleObject		cp_menuisElem_cadre
name:"Cadre"
classID:#(0x191d683f, 0x345d8d04)
category:"CP | Menuiserie	| Element"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuisElem_cadre"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Pr�d�finitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -------------
		menuis_epaisseur	 	type:#worldUnits 	ui:spn_menuis_epaisseur	default:0.
		
		------ options --------------
		montant_G				type:#boolean 		ui:shk_montant_G		default:true
		montant_D				type:#boolean 		ui:shk_montant_D		default:true
		travBasse				type:#boolean 		ui:shk_traverse_B		default:true
		travBasse_hauteur	type:#worldUnits 	ui:spn_travBasse_ht		default:0.
		
		----- pour rester dans valeurs corrects ------------------------
		on menuis_epaisseur 		set val do corriger_parametres ()
		on longueur 				set val do corriger_parametres ()
		on hauteur 				set val do corriger_parametres ()
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ mat ID ----------
		matId_menuis			type:#integer 			ui:spn_matId_menuis	default:1
		
		qualite					type:#integer 			ui:rdo_qualite				default:1
		
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Param�tres"
	(
-- 		group "Global" (
			spinner spn_longueur 			"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
-- 		)
		group "Menuiserie" (
			spinner 	spn_menuis_epaisseur	 "Epaisseur" 				type:#worldunits range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 		
			checkbox	shk_traverse_B		"traverse basse" 	
			spinner 	spn_travBasse_ht	"Hauteur" 				type:#worldunits range:[0,1e20,0]
		)
		fn actualiser = (
			
			spn_travBasse_ht.Indeterminate 			= not travBasse
			spn_travBasse_ht.enabled 					= travBasse
		)
		on roll_general		open 					do actualiser ()
		on shk_traverse_B	changed state 	do actualiser ()
	)
	rollout roll_divers  "Divers" (
		
		group "Qualit�" (
			radioButtons rdo_qualite 		"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
		)
		
	) ---- fin rollout	----------
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		local longueurMax	=	longueur/2
		if not montant_G	and montant_D 	or not montant_D	and montant_G do longueurMax = longueur
		local hauteurMax		= hauteur /2
		if not	travBasse do hauteurMax =	hauteur
		
		if montant_G	or  montant_D 	do
			if menuis_epaisseur >longueurMax do menuis_epaisseur = longueurMax
		if menuis_epaisseur > hauteur -   travBasse_hauteur do menuis_epaisseur =  hauteur -   travBasse_hauteur 
	)
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		--- Donn�es  ---------------------------------------------------------------------------------------
		local posX_traverses	=	0
		local long_trav	=	longueur
		if montant_G	do (
			long_trav 			-= menuis_epaisseur
			posX_traverses 	+= menuis_epaisseur
		)
		if montant_D	do long_trav -= menuis_epaisseur
		
		
		
		
		
		
		
		--- Construction ---------------------------------------------------------------------------------------
		----- les composants ----------------		
		local composant
		case qualite	of (
			1:	composant	=	 createInstance  cp_prim_boite				matId:matId_menuis
			2:	composant	=	 createInstance  cp_prim_boiteL				matId:matId_menuis
			3:	composant	=	 createInstance  cp_prim_planVertical		matId:matId_menuis
		)
		
		
		
		--- montant  gauche ----------
		if montant_G do (
			composant.longueur			=	menuis_epaisseur
			composant.hauteur			=	hauteur
			if qualite != 3 do	
				composant.profondeur		=	profondeur
			
			mgr_mesh.attacher		mesh		composant
			
		)
		
		--- montant droite ----------
		if montant_D do (
			composant.longueur			=	menuis_epaisseur
			composant.hauteur			=	hauteur
			if qualite != 3 do	(
				composant.profondeur		=	profondeur
				composant.symetrie			=	true
			)
			mgr_mesh.attacher		mesh		composant 	transf:[longueur - menuis_epaisseur,0,0]				
		)
		
		--- traverse basse ----------
		if travBasse do (			
			composant.longueur			=	long_trav
			composant.hauteur			=	travBasse_hauteur
			if qualite != 3 do	(
				composant.profondeur	=	profondeur
				composant.symetrie		=	false
				composant.horizontal		=	true
			)
			mgr_mesh.attacher		mesh		composant 	transf:[posX_traverses,0,0]				
		)
		
		--- traverse	haute ----------
		composant.longueur			=	long_trav
		composant.hauteur			=	menuis_epaisseur
		if qualite != 3 do	 (
			composant.profondeur	=	profondeur
			composant.symetrie		=	true
			composant.horizontal		=	true
		)
		
		mgr_mesh.attacher		mesh		composant 	transf:[posX_traverses,0,hauteur - menuis_epaisseur]
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
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
				5: #stop
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
				5: (
					menuis_epaisseur 				= length ( gridPoint - pt_epaisseur )
					travBasse_hauteur 	= menuis_epaisseur 
				)
			)		
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------











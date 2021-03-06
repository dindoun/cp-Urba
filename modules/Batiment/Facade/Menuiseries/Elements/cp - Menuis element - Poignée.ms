
plugin simpleObject		cp_menuisElem_poignee
name:"Poign�e"
classID:#(0x277c59b6, 0x7c0f72eb)
category:"CP | Menuiserie	| Element"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuisElem_poignee"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Pr�d�finitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	--- composant ---
	local composant_boite
	
	parameters params_general 	rollout:roll_general		(
		symetrie_sens		type:#boolean 		ui:shk_symetrie_sens		default:false
		symetrie				type:#boolean 		ui:shk_symetrie		default:false
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		matId				type:#integer 			ui:spn_matId		default:3
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Poignee"
	(
		
		checkbox	shk_symetrie_sens	"symetrie_sens"
		checkbox	shk_symetrie			"symetrie"
		group "Qualit�" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
			spinner 	spn_matId 				"MatID" 			type:#integer range:[1,1000,1]
		
	) ---- fin rollout	----------
	
	
	
	

	
	
--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		local compo_base = if  qualite == 3  then  cp_prim_planVertical	 else cp_prim_boite
		composant_boite =createinstance	compo_base 	matId:matId
		
		---- plaque	----------
		composant_boite.longueur			=	4	
		composant_boite.hauteur			=	18	
		if not  qualite == 3   do	composant_boite.profondeur		=	0.5
		local posY = if symetrie then  posY = -.5	else 0
		
		mgr_mesh.attacher mesh composant_boite 	transf:[0, posY, 0]
		
		
		
		
		---- poign�e part 1	----------
		composant_boite.longueur		=	if not  qualite == 3   then	1		else 2.5
		composant_boite.hauteur		=	1
		if not  qualite == 3   do	composant_boite.profondeur		=	2.5
		local posY = if symetrie then  posY = -3	else 0.5
		
		if not  qualite == 3  then 
			mgr_mesh.attacher mesh composant_boite 	transf:[1.5, posY, 11.5]
		else (
			local transfo	=	if not symetrie_sens 	then	rotateZMatrix 	90	*	transMatrix	[2.5, posY, 11.5] 
																	else	rotateZMatrix 	90	*	transMatrix	[1.5, posY, 11.5] 
			
			mgr_mesh.attacher mesh composant_boite 	transf:transfo
			
		)
		
		---- poign�e part 2	----------
		local decalle_x = 1.5
		if	not symetrie_sens then	decalle_x = -7.5		
		composant_boite.longueur			=	10
		composant_boite.hauteur			=	1
		if not qualite == 3  do	composant_boite.profondeur		=	1
		local posY = if symetrie then  posY = -3	else 3
		
		mgr_mesh.attacher mesh composant_boite 	transf:[ decalle_x , posY, 11.5]
		
	
	)  ----- fin on buld mesh -----------------  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	nodeTM.translation = gridPoint
						#stop
					)
			)
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------











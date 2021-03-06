
-- include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - mgr - Datas to string.ms" 

struct str_tmp	(		--		struct str_terrain_outils_shape (
		
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | shape"	  	var:var	 param:param		catch (),
		m_tab_format_nd = "		",
		fn	format_noeud  _nd = if m_debug do (			 
			local indent_prfix = "|    "
			format (  m_tab_format_nd + _nd.nom + "\n" )
			if _nd.enfants.count >0 	do	m_tab_format_nd += indent_prfix
			for enft in _nd.enfants 	do 	format_noeud enft
			if _nd.enfants.count >0 	do	m_tab_format_nd = substring m_tab_format_nd 1 (	m_tab_format_nd.count -	indent_prfix.count )
		),
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		precision_courbe 		= 50,			--- en cm. ----
		
-- 	private
	public --- DEBUG en est en private normalement ----
		
		fn comparer_tabs 	first 	second =
		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
	
		----------------- tableaux -----------------
		fn boucler 							_array				_id_item 		=(
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
	
	
	
		--- Analyse position de points (survol etc..)		-------------
		fn est_aGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
			sens
			
		),
		fn est_dansTriangle		_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester =(
			if est_aGauche  _pt_tri_1 	_pt_tri_2 	_pt_aTester and est_aGauche  _pt_tri_2 	_pt_tri_3 	_pt_aTester  and est_aGauche  _pt_tri_3 	_pt_tri_1 	_pt_aTester then (
-- 				if _pt_aTester == _pt_tri_1 or _pt_aTester == _pt_tri_2 or _pt_aTester == _pt_tri_3 then
-- 					false
-- 				else
					true
			) else false
		),
		fn survol  					_pt_aTester			_pts_triangles_shape 	=(
			local result = false
			for pts_tri in _pts_triangles_shape do
				if est_dansTriangle		pts_tri[1]	pts_tri[2]	pts_tri[3]	_pt_aTester do
					result = true
			result			
		),
		fn BBs_seCroisent		_shp_1  	_shp_2	 =(
			
			local BB_1 = get_BB_shape	_shp_1
			local BB_2 = get_BB_shape	_shp_2
			
			local result = true
			if BB_1[1].x > BB_2[2].x  	do result = false
			if BB_1[2].x < BB_2[1].x  	do result = false
			
			if BB_1[1].y > BB_2[2].y  	do result = false
			if BB_1[2].y < BB_2[1].y  	do result = false
			result
		),
		
		
		
		
		
		----- accessions divers  ----------------------------
		--- points ------------
		fn get_longueur_segment	_shp	_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	_shp 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		_shp	_id_spline
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
			
			longueur_result
			
		),
		fn	get_angleVecteurs v1 v2 =(
-- 			debug "get_angleVecteurs"
-- 			debug "dot (normalize v1) (normalize v2)" var:(dot (normalize v1) (normalize v2))
			local result_angle
			if abs (dot (normalize v1) (normalize v2)) == 0 then 
				result_angle = 0
			else
				result_angle = acos(dot (normalize v1) (normalize v2))
-- 			format "angle entre vec :%\n" result_angle
			result_angle
		),
		fn get_distance_point_segment		_pt		_seg_pt1	_seg_pt2 =(
			
			local pt 			= _pt
			local vec_1 		= (_seg_pt2  -  _seg_pt1)
			local vec_2 		=  ( _pt  -  _seg_pt1)
			
			local angle_test 	= get_angleVecteurs    vec_1 vec_2
			
			local dist_result 	= abs ( ( dot  vec_1  vec_2 ) * tan  angle_test )
			dist_result
			
		),
		fn get_aire_triangle	_pts_triangle =(
			debug "get_aire_triangle"
			local l 		= 	distance	_pts_triangle[1]	_pts_triangle[2]
			local h		=	get_distance_point_segment  _pts_triangle[3]	_pts_triangle[1]	_pts_triangle[2]
			debug "L" var:l
			debug "h" var:h
			local aire 	= l * h / 2
			aire
		),
		
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
			local pt_intersec			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x != 0 then (				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
			)
			
			pt_intersec
			
		),		
		fn point_lePlusHautSurY 			_pts		=(
			local maxi = _pts[1].y
			local result_id = 1
			for i = 1 to _pts.count do (
				local pt = _pts[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "point_lePlusHautSurY"	var:result_id
			result_id
		),
		fn point_lePlusAGauche		_pts =(
			local index = 0
			local minX = 1e10
			
			for i = 1 to _pts.count do (
				if _pts[i].x < minX do (
					minX = _pts[i].x
					index = i
				)
			)
			
			index
		),	
		fn point_lePlusLoinDuSegment 			_pts			_pt_seg1		_pt_seg2 	=(
			
			local result_index 	= 0
			local dist_max 		= -1e+10
			for i = 1 to _pts.count do (
				/* 
				local pt 			= _pts[i]
				local vec_1 		= (_pt_seg2  -  _pt_seg1)
				local vec_2 		=  ( pt  -  _pt_seg1)
				
				local angle_test 	= get_angleVecteurs    vec_1 vec_2
				
				local dist_test 	= abs ( ( dot  vec_1  vec_2 ) * tan  angle_test ) */
				
				local dist_test  = get_distance_point_segment  	_pts[i]			_pt_seg1		_pt_seg2
				
				if dist_test > dist_max do (
					dist_max 		= dist_test
					result_index 	= i
				)
			)
			result_index
		),
		
		
		
		
		
		--- shapes ------------
		fn get_BB_shape		_pts_shp 	=(
			local result #([0,0,0],[0,0,0])
			
			
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for pt in _pts_shp do (
				if pt.x < minX 		do minX = pt.x 
				if pt.y < minY 	do minY = pt.y
				if pt.z < minZ 		do minZ = pt.z 
				if pt.x > maxX 	do maxX = pt.x 
				if pt.y > maxY 	do maxY = pt.y 
				if pt.z > maxZ 	do maxZ = pt.z 
			)
			
			#([minX,minY,minZ],[maxX,maxY,maxZ])
			
		),
		fn get_aire_BB  		_pts_shp 	=(
			local BB 		= get_BB_shape		_pts_shp
			(BB[2].x - BB[1].x) * (BB[2].y - BB[1].y)
		),
		fn get_lePlusGros_shape	_pts_shps =(
			local aireMax = 0
			local id_result = 0
			for i = 1 to _pts_shps.count do (
				local pts_shp = _pts_shps[i]
				local aire = get_aire_BB 	pts_shp
				if aire> aireMax do (
					id_result = i
					aireMax = aire
				)
			)
			id_result
		),
		fn get_lePlusPetit_shape	_pts_shps =(
			local aireMin = 1e+20
			local id_result = 0
			for i = 1 to _pts_shps.count do (
				local pts_shp = _pts_shps[i]
				local aire = get_aire_BB 	pts_shp
				if aire< aireMin do (
					id_result = i
					aireMin = aire
				)
			)
			id_result
		),
		fn get_distance_shapes  _pts_shp1  _pts_shp2 =(
			
			struct	str_dist_shapes	(
				id_pt_shp1	=	0,
				id_pt_shp2	=	0,
				distance		= 1e+10
			)
			
			
			local id_pt_connexion_1	=	0
			local id_pt_connexion_2	=	0 
			local dist_min					= 1e+10
			local result 
			
			for id_pt1 = 1 to  _pts_shp1.count do (
				local pt1	=	_pts_shp1[ id_pt1 ]
				for id_pt2 = 1 to  _pts_shp2.count do (
					local pt2			=	_pts_shp2[ id_pt2 ]
					local dist_test	=	distance	pt1 pt2
					if dist_test < dist_min do (
						dist_min = dist_test
						id_pt_connexion_1	=	id_pt1
						id_pt_connexion_2	=	id_pt2
						result = str_dist_shapes  id_pt_shp1:id_pt1	id_pt_shp2:id_pt2	distance:dist_test
					)				
				)
			)
			
			result
			
		),
		fn get_shape_lePlusProche	_pts_shp1		_pts_shps_aTester 		=(
			
			struct	str_shape_lePlusProche	(
				id_shp 		= 	0,
				id_pt_shp1	=	0,
				id_pt_shp2	=	0
			)
			
			local dist_min	= 1e+10
			local result = str_shape_lePlusProche ()
			
			local pts_shp1	= _pts_shp1
			
			for  i = 1 to _pts_shps_aTester.count do (
				local pts_shp2	= _pts_shps_aTester[ i ]
				
				local dist_test = get_distance_shapes 	pts_shp1  	pts_shp2
				if dist_test.distance < dist_min do (
					dist_min = dist_test.distance					
					result.id_shp 		= 	i
					result.id_pt_shp1	=	dist_test.id_pt_shp1
					result.id_pt_shp2	=	dist_test.id_pt_shp2
				)
			)
				
			result
		),
		fn get_id_shp_enfant_proche 		_shp_1  	shps_tests 	=(
			
			local result = 0
			if _shp_1.count != 0 then (
				--- on cherches les shapes qui sont � l'interieur -------
				local shps_interieur =#()
				for shp in shps_tests do
					if shape_estDans_shape	 _shp_1 		shp do
						append shps_interieur	shp
				
				--- si on a des shapes � l'interieur ---------------
				--- parmis ceux � l'interieur on prend le plus proche ---------------------------
				if shps_interieur.count > 0 do 
					result 	= 	( get_shape_lePlusProche 		_shp_1	shps_interieur ).id_shp
					
			) else result = 1
			
			result
		),
		fn get_ids_shapes_aLInterieur		_shp		_shps_aTester  =(
			local ids_result =#()
			for i = 1 to _shps_aTester.count do (
				local shp_aTester = _shps_aTester[i]
				if shape_estDans_shape 	_shp 	shp_aTester  do
					append  ids_result		i
			)
			ids_result
		),
		fn get_aire_shape	_pts_shp	 =(
			
			local triangles_duShape 	= 	this.trianguler 	_pts_shp
			local result_aire 				=	0
			for tri in triangles_duShape do result_aire +=	get_aire_triangle	tri
			result_aire
		),
		
		
		
		--- sens du shape ----------------------
		fn est_sensPositif 					_pts 		=(
-- 			debug "est_sensPositif"
			local result 				= true
			local id_pointHaut 	=  point_lePlusHautSurY  	_pts
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _pts.count
			if id_pt_2 > _pts.count  do id_pt_2 = 1
			
			local	pt_1 		= _pts [	id_pt_1		]
			local	pt_ori 		= _pts [	id_pt_ori	]
			local	pt_2 		= _pts [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
-- 			debug "est_sensPositif" var:result
			
			result
			
		),
		fn changer_sens 					_pts 		=(
-- 			debug "changer_sens"
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result 	_pts[i]
			result
		),
		fn BBs_seCroisent		_shp_1  	_shp_2	 =(
			local result = true
			if _shp_1.count > 0 do 	(
				local BB_1 = get_BB_shape	_shp_1
				local BB_2 = get_BB_shape	_shp_2
				
				if BB_1[1].x > BB_2[2].x  			then result = false
				else if BB_1[2].x < BB_2[1].x  	then result = false
				else if BB_1[1].y > BB_2[2].y  	then result = false
				else if BB_1[2].y < BB_2[1].y  	do result = false
			)
			result
		),
		------- renvois la position d'un shape par rapport � un autre: si un shapes est ' l'interieur d'un autre (trou boolean), se croisent ou � l'exterieur ---------
		fn get_positionRelative_shapes 		_pts_shp1		_pts_shp_aTester 	=(
			
-- 			debug "get_positionRelative_shapes"
			
			struct	str_intersection	(
				pos,
				id_pt_1 =0,
				id_pt_2 =0				
			)
			
			
			local result = #aCot�		---- #exterieur,  #interieur, #intersection, ou	 #aCot�	 --------------
			local intersections =#()
			
			if  BBs_seCroisent 	_pts_shp1 		_pts_shp_aTester do (
			
				---- on regadre si les edges se coupent --- si oui --->  #intersection -----------------
				local se_coupent = false
				local  i = 1
				while i <= _pts_shp1.count and not se_coupent do (
					
					local pt_shp1			= _pts_shp1[ i ]
					local i_svt	=	if i == _pts_shp1.count  then 1 else i + 1
					local pt_shp1_svt	= _pts_shp1[ i_svt ]
					
					local  j = 1
					while j <= _pts_shp_aTester.count and not se_coupent do (
						
						local pt_shp2			= _pts_shp_aTester[ j ]
						local j_svt	=	if j == _pts_shp_aTester.count  then 1 else j + 1
						local pt_shp2_svt	= _pts_shp_aTester[ j_svt ]
						
						local intersection = get_intersection_vecteurs		pt_shp1   pt_shp1_svt		pt_shp2		pt_shp2_svt 
						if intersection != undefined do (
							append intersections ( str_intersection pos:intersection		id_pt_1:i 	id_pt_2:j 	)
							se_coupent = true
						)
						j+= 1
					)
					i+= 1
				)
				
				---- si on a des intersections, alors ils se croisent ------------------------------------
				if intersections.count > 0 then
					result = #intersection
				
				else (
					---- s'il ne se croisent pas alors ils sont tout � l'interieur ou � l'extierieur l'un de l'autre -------------------------
					local pts_triangles_shp1 = this.trianguler	_pts_shp1
-- 					local pts_triangles_shp2 = this.trianguler	_pts_shp_aTester
					
					if survol  	_pts_shp_aTester[1]	pts_triangles_shp1	 then 
						result = #interieur
					else -- if survol  	_pts_shp1[1]		pts_triangles_shp2	 then 
						result = #exterieur
						
				)
				
			)
			
			result
		),
		
		fn shape_estDans_shape		_shp_1  shp_test =(
			if _shp_1.count == 0 then 			
				true
			else 	if not BBs_seCroisent	_shp_1	shp_test then
				false	
			else if get_positionRelative_shapes  _shp_1	shp_test  == #interieur then 
				true
			else 
				false
		),
		
		
		
		
		
		
		
		
		fn get_idsPts_connexion   	_pts_shp1		_pts_shp2 =(
			local results = #()
			
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			
			local dist_min					= 1e+10			
			for id_pt1 = 1 to  _pts_shp1.count do (
				local pt1	=	_pts_shp1[ id_pt1 ]
				for id_pt2 = 1 to  _pts_shp2.count do (
					local pt2			=	_pts_shp2[ id_pt2 ]
					local dist_test	=	distance	pt1 pt2
					if dist_test < dist_min then (
						
						local id_pt2_svt	=	if id_pt2 == _pts_shp2.count  then 1 else id_pt2 + 1
						local pt_2_svt 		= _pts_shp2[ id_pt2_svt ]
						---- si plus proche --------------
						dist_min = dist_test
						results = #()
						append results 	#( id_pt1 , id_pt2 )
					) else
					if abs ( dist_test - dist_min )  == 0   then (
						append results 	#( id_pt1 , id_pt2 )
					)
					
				)
				
			)
			results
		),
		
		
		
		------------------ Preparation pour geometrie -----------------------------------
		fn ajouter_shape_aBooleen			_pts_shp_booleen		_pts_shp_aAjouter	 =(
			
-- 			debug "ajouter_shape_aBooleen"
			
			local chrono_temp = timeStamp ()
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			local connexions	=	get_idsPts_connexion   	_pts_shp_booleen		_pts_shp_aAjouter 
			
			
			
			
-- 			debug"connexions" var:connexions
			local connexion = connexions[1]
			--- si on a plusieurs connexions ------------------
			if connexions.count > 1 then (
				
				local id_pt_origine 	= connexions[1][2]
				local pt_origine 		= _pts_shp_aAjouter[id_pt_origine]
				
				local angle_min 			= 1e+10
				while connexions.count > 1 do (
					
					---- si on a des connexion vers le meme point ------------------
					if id_pt_origine == connexions[2][2] then (
						
						local	id_pt_cnx1			= connexions[1][1]
						local id_pt_cnx1_svt	=	if id_pt_cnx1 == _pts_shp_booleen.count  then 1 else id_pt_cnx1 + 1
						local id_pt_cnx1_prcd	=	if id_pt_cnx1 == 1  then _pts_shp_booleen.count else id_pt_cnx1 - 1
						
						local pt_cnx1 			= _pts_shp_booleen[id_pt_cnx1]
						local pt_cnx1_svt	= _pts_shp_booleen[id_pt_cnx1_svt]
						local pt_cnx1_prcd	= _pts_shp_booleen[id_pt_cnx1_prcd]
						
						if pt_cnx1_svt == pt_cnx2_prcd then (
							local pt_est_aGauche 	= est_aGauche		pt_cnx1		pt_cnx1_svt		pt_origine	
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						) else (
							local pt_est_aGauche 	= est_aGauche		pt_cnx1_prcd		pt_cnx1		pt_origine
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						)
					) 
					deleteItem connexions 1
				)
			)   
			
			local id_pt_connexion_1 =	connexion[1]
			local id_pt_connexion_2 =	connexion[2]
			
			
-- 			debug  ("	TIME:	on cherche les points des shpes les plus proches pour les connecter : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les premier shape -----------
			local pts_result = #()
			if id_pt_connexion_1 != 0 do (
				pts_result = #( _pts_shp_booleen[ id_pt_connexion_1 ] )
				for i_compteur = 1 to  _pts_shp_booleen.count do (
					local id_pt = i_compteur + id_pt_connexion_1 
					if id_pt > _pts_shp_booleen.count do 
						id_pt -= _pts_shp_booleen.count 
					local pt = _pts_shp_booleen[id_pt]
					append pts_result	pt
				)
			)
			
-- 			debug  ("	TIME:	les premier shape : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les second shape, on l'ajoute a l'envers  -----------
			for i_compteur =  _pts_shp_aAjouter.count to 1 by -1 do (
				local id_pt = i_compteur + id_pt_connexion_2 
				if id_pt > _pts_shp_aAjouter.count do 
					id_pt -= _pts_shp_aAjouter.count 
				local pt = _pts_shp_aAjouter[id_pt]
				append pts_result	pt
			)
			if id_pt_connexion_2 != 0 do
				append 	pts_result	( _pts_shp_aAjouter[ id_pt_connexion_2 ] )
			
-- 			debug  ("	TIME:	les second shape, on l'ajoute a l'envers : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			
			pts_result
			
		),
		fn creer_pts_pourFace			_noeud			=(
			
-- 			local chrono_temp = timeStamp ()
			
			local pts_result 	=	#()
			local pts_noeud 	=	_noeud.get_pts	()
			
			---- Version on prend les enfants 1 par 1 le plus pret ----------------------
			local enfants_a_traiter	 = deepcopy _noeud.enfants
			while enfants_a_traiter.count > 0 do (
				
				local shps_enfants_a_traiter	=	for enfant in enfants_a_traiter collect enfant.pts
				local infos_enfant_proche		=	get_shape_lePlusProche	pts_noeud		shps_enfants_a_traiter
				local enfant_proche				=	 enfants_a_traiter[ infos_enfant_proche.id_shp ]
				
				pts_noeud = ajouter_shape_aBooleen  	pts_noeud		( enfant_proche.get_pts() )
				
				for petitEnfant in enfant_proche.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
				
				deleteItem enfants_a_traiter  infos_enfant_proche.id_shp 
			) 
			
			/* ---- Version on prend les enfants 1 par 1 a la suite ----------------------
			for enfant in _noeud.enfants do (
				pts_noeud = ajouter_shape_aBooleen  		pts_noeud		( enfant.get_pts() )
				for petitEnfant in enfant.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
			)
			*/
			append pts_result 	pts_noeud
-- 			debug  ("	TIME:	creer_pts_pourFace : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			pts_result
		),
		fn get_pts_from_hierachie		_noeud_root	=(
			
			local pts_result =#()
			
			for enfant in _noeud_root.enfants do 
				pts_result += creer_pts_pourFace  enfant
			
			pts_result
			
		),
		
		
		
		
		
		------------------ hierarchie booleenne -----------------------------------
		fn creer_noeud_hierarchie 	pts: 	nom:	=(
			
			---- noeud de la hierarchie ----------
			struct str_terrain_booleen_node (
				
-- 					struct_prt ,
					
				
				public
					pts 			=	#(),
					nom 			="",
					dist_auParent = 0,
					
					parent,
				public
					enfants		=	#(),
					
					fn set_parent		_ndParent = (
						if parent != undefined and parent  != _ndParent do
							parent.retirer_enfant	this
						parent  = _ndParent
					),
					fn ajouter_enfant 	_neudEnfant 	distance_toParent	= (
						local distTest	=	distance_toParent	--struct_prt.get_distance_shapes 	pts	_neudEnfant.pts
						
						local trouve = false
						if distTest != undefined do (
								
							local	dist_au_nvl_enfant	 		= distTest.distance
							
							_neudEnfant.dist_auParent 		= dist_au_nvl_enfant
							
							local id_cible = 0
							local i = 1
							while i <= enfants.count and not trouve do (
								local enfant = enfants[i]
								if dist_au_nvl_enfant <	 enfant.dist_auParent do (
									insertItem	_neudEnfant 	enfants	i
									trouve = true
								)
								i += 1
							)
						)
						if not trouve do
							append enfants  _neudEnfant
						
						
						_neudEnfant.set_parent  	this
					),
					fn retirer_enfant	_enfant =(
						local id_enfant = findItem enfants	_enfant
						if id_enfant != 0 do
							deleteItem enfants id_enfant
					),
					fn set_pts  _pts= pts = _pts,
					fn get_pts  = pts
					
			)--- fin du struct----
			
		
			
			local nv_noeud = str_terrain_booleen_node	()--	struct_prt:this
			if pts != unsupplied do (
				if not est_sensPositif pts do 
					pts = changer_sens pts
				
				nv_noeud.set_pts 	pts
			)
			if nom != unsupplied do nv_noeud.nom= nom
			nv_noeud
			
		),
		fn integrer_nd_dans_hierarchie		_nd_courant		_nd_aIntegrer 	=(
			
			local integration_reussie = false			
			
			
-- 			local chrono_temp 		= timeStamp ()
-- 				local chrono_temp 		= timeStamp ()
			local est_dans_shape 	= shape_estDans_shape		_nd_courant.pts  	( _nd_aIntegrer.get_pts ())					
-- 				debug  ("	TIME:	integrer_nd_dans_hierarchie / est_dans_shape  : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 				local chrono_temp = timeStamp ()
			if est_dans_shape	then (
				
				integration_reussie = true
				
				---- les enfants -----
				local integration_dans_enfant = false	
				for enfant in	_nd_courant.enfants  do (
					
					local integration = integrer_nd_dans_hierarchie  		enfant  		_nd_aIntegrer
					if integration then  
						integration_dans_enfant = true
				)
				
				if not integration_dans_enfant   do (
					
					local enfants_a_ajouter =#()
					for enfant in	_nd_courant.enfants  do (		
						if shape_estDans_shape	( _nd_aIntegrer.get_pts () )	enfant.pts   then
							append enfants_a_ajouter enfant
					)
					
					for enfant in enfants_a_ajouter do (
						local distance_toParent = get_distance_shapes 	_nd_courant.pts	enfant.pts
						_nd_aIntegrer.ajouter_enfant 	enfant	distance_toParent
					)
					
					local distance_toParent = get_distance_shapes 	_nd_courant.pts	_nd_aIntegrer.pts
					_nd_courant.ajouter_enfant 		_nd_aIntegrer	distance_toParent
				) 
				
			) 
			
			
			integration_reussie
			
		),
		
		fn addition_booleenne	_shp_1	_shp_2 =(
			
			debug "addition_booleenne"
			struct	str_intersection	(
				pos,
				id_pt_courant 	=	0,
				id_pt_autre 	=	0
			)
			
			---- les points � traiter	-------------
			local pts_restant_shp1 =#{1.._shp_1.count}
			local pts_restant_shp2 =#{1.._shp_2.count}	
			
			--- on retire les points dans les surfcaes --------		
			local triangles_shp1	=	this.trianguler 	_shp_1
			local triangles_shp2	=	this.trianguler 	_shp_2
			for i in 1 to _shp_1.count do (
				local pt = _shp_1[i]
				if survol  	pt		triangles_shp2 do
					pts_restant_shp1[i] = false
			)
			for i in 1 to _shp_2.count do (
				local pt = _shp_2[i]
				if survol  	pt		triangles_shp1 do
					pts_restant_shp2[i] = false
			)
			
			
			
			
			
			
			local shp1				= deepcopy _shp_1
			local shp2				= deepcopy _shp_2
			
			
			local shp_courant	=	shp1
			local shp_autre		=	shp2
			local id_pt_courant	=	(pts_restant_shp1 as array )[1]
			local pt_courant		=	shp_courant[ id_pt_courant ]
			
			local shp_initial 		=	shp_courant
			local id_pt_initial		=	id_pt_courant
			local pt_initial			=	pt_courant
			local sens				=	1
			
			local shps_results 	=	#()			
			
			local sauvetage1 = 0
			local sauvetage2 = 0s
			local	il_reste_des_points =true
			while	il_reste_des_points	and sauvetage1 < 20  do (
				sauvetage1 += 1 
				format "\n-------------  NOUVEAU SHAPE	----------------\n"
				local shp_courant_result 		=	#(pt_courant)
				local on_continue	= true
				
				while on_continue	and sauvetage2 < 100 do (
					sauvetage2 += 1 
					format "-----------------------------\n"
					format "id_pt_courant : %\n"  id_pt_courant
					format "shp_courant : %\n"  shp_courant
					
					commencement = true
					
					local id_pt_suivant 	=  id_pt_courant + sens
					if id_pt_suivant 	> shp_courant.count do id_pt_suivant = 1
					if id_pt_suivant 	< 1 do id_pt_suivant = shp_courant.count
					local pt_suivant 		= shp_courant[ id_pt_suivant ]
					
						
						
					--- on cherche si intersection avec l'autres shapes ----
					local intersections = #()
					for j = 1 to shp_autre.count do (
						
						local pt_autre			= shp_autre[ j ]
						local j_svt				=	j + sens
						if j_svt > shp_autre.count  do j_svt = j_svt - shp_autre.count
						if j_svt < 1   do j_svt = j_svt + shp_autre.count
						
						local pt_autre_svt	= shp_autre[ j_svt ]
						
						local intersection = get_intersection_vecteurs		pt_courant   pt_suivant		pt_autre		pt_autre_svt 
						if intersection != undefined and distance intersection 	pt_courant > .1 do
							append intersections ( str_intersection pos:intersection		id_pt_courant:id_pt_courant 		id_pt_autre:j 	)
					)
					
					
					
					if intersections.count > 0 then (
						
						format "	--->	intersection\n"
						---- on prend la premiere intersection, la plus proche --------
						local distMin =	1e+10
						local intersection 
						for intersec in intersections do 
							if distance pt_courant intersec.pos < distMin do (
								intersection = intersec
								distMin = distance pt_courant intersec.pos
							)
						
-- 						point pos:intersection.pos name:"intersection" 
						
						--- on change de shape ----------------
						
						if est_aGauche 	pt_courant 	pt_suivant 		shp_autre[ intersection.id_pt_autre ] then (
							sens = 1 
							id_pt_courant = intersection.id_pt_autre 
						) else  (
							sens = -1
							id_pt_courant = intersection.id_pt_autre +1
							
						)
						if comparer_tabs	shp_courant  shp1 then (
							format "	--->	on est sur shp1, on passe sur shp2\n"
							
							shp_courant 	= 	shp2
							shp_autre		=	shp1
						) else (
							format "	--->	on est sur shp2, on passe sur shp1\n"
							shp_courant 	= 	shp1
							shp_autre		=	shp2
						)
						
						pt_courant = intersection.pos
						
					) else (
						
						format "	--->	point suivant\n"
						---- point suivant ----------
						id_pt_courant 	+=  sens
						
						if id_pt_courant 	> shp_courant.count do id_pt_courant = 1
						if id_pt_courant 	< 1 do id_pt_courant = shp_courant.count
						
						pt_courant			=	shp_courant[ id_pt_courant ]
						
						---- on retire de la liste des points restant--------------
						if comparer_tabs	shp_courant  shp1 then 
							pts_restant_shp1[id_pt_courant] = false
						else
							pts_restant_shp2[id_pt_courant] = false
						
					)
					
					
					if ( comparer_tabs	shp_initial 	shp_courant  and id_pt_courant == id_pt_initial and pt_courant == pt_initial ) then (
						on_continue = false
						format "	---------	FIN	------------\n"
					) else (
						--	on ajoute le point --
						append shp_courant_result 	pt_courant
					)
					
					format "-----------------------------\n"
					
				) --- fin while -------------------------------------------------
				
				
				append 	shps_results	shp_courant_result
				
				if ( pts_restant_shp1 as array).count >0 then (
					
					id_pt_courant 		=	( pts_restant_shp1 as array)[1]
					shp_courant 		= 	shp1
					shp_autre			=	shp2
					pt_courant			=	shp_courant[ id_pt_courant ]
					
				) else if ( pts_restant_shp2 as array).count >0 then (
					id_pt_courant 		=	( pts_restant_shp2 as array)[1]
					shp_courant 		= 	shp2
					shp_autre			=	shp1
					pt_courant			=	shp_courant[ id_pt_courant ]
					
				) else 	il_reste_des_points = false
				
				shp_initial 		=	shp_courant
				pt_initial			=	pt_courant
				id_pt_initial		=	id_pt_courant
				sens				=	1
				
			) --- fin while il reste des points --------------------------------
			
			
			shps_results
		),
	
	
		fn preparer_booleens 	_pts_shapes	=(
			local chrono_temp = timeStamp ()
			
			debug "preparer_booleens"
			local pts_shps = deepCopy _pts_shapes	
			local pts_shps_result 	=	#()
			
			
			local 	nd_root			=	creer_noeud_hierarchie 	nom:"root"	
			local 	shps_aTraiter	=	deepCopy pts_shps
			
			local i = 1
			for shp in  	shps_aTraiter  do (
				local nv_nd = 	creer_noeud_hierarchie 		pts:shp	nom:("noeud " + i as string )
				integrer_nd_dans_hierarchie		nd_root		nv_nd
				i+=1
			)
			
			debug  ("	TIME:	preparer les booleens : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			local chrono_temp = timeStamp ()
			
			local		pts_result	= get_pts_from_hierachie		nd_root
			debug  ("	TIME:	transformer points depuis hierarchie : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			
-- 			format "------------final---------\n"
-- 			format_noeud 	nd_root
			
			pts_result
		),
		
		
		
		
	
		----- manipulation de  points  ---------------
		fn nettoyer_points_inutiles	_pts	 	_seuil:.9999		=(
			
			local dotmax_courbe 	= _seuil	--- en dot ?!?. ----
			local pts_result 			= deepCopy	_pts
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to  pts_result.count do (
				
				local pt_result 			= 	#()
				local ids_aSupprimer 	=	#()
				local pts 					= 	pts_result[id_spline_contour]
				
				for id_pt_contour	=	1	to pts.count do (
					
					local pt_contour  = pts[ 	id_pt_contour]
					local id_pt_svt 	= if id_pt_contour == pts.count then 1 else id_pt_contour + 1
					local pt_suivant  = pts[ 	id_pt_svt ]
					
					local id_pt_avt	= if id_pt_contour == 1 then pts.count else id_pt_contour - 1
					local pt_precedant  = pts[ id_pt_avt ]
					
					local vec_1 = pt_suivant 		- pt_contour
					local vec_2 = pt_precedant 	- pt_contour
					
					
					local dot_vecs = dot (normalize vec_1) 	(normalize vec_2)
					
-- 					debug "------------>	dot_tangents" var:dot_tangents
					
					if abs dot_vecs >=	dotmax_courbe do (
						append ids_aSupprimer 	id_pt_contour
					)
					
				)
				
				
				for i = ids_aSupprimer.count to 1 by -1 do
					deleteItem pts_result[id_spline_contour]  ids_aSupprimer[i]
				
			)
			
			pts_result
		),
		fn interpoler_shape 	_shp		=(
			
			local result	=#()
	
			local dotmax_courbe 		= .999	--- en dot ?!?. ----
			
			m_pts_contour = #()
			
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to numsplines  _shp do (
				
				local pts_spline_contour = for j= 1 to numKnots 	_shp	id_spline_contour	 collect getKnotPoint _shp 		id_spline_contour	 	j 
				local pt_result 	= #()
				for id_pt_contour	=	1	to pts_spline_contour.count do (
					
					local pt_contour  		= getKnotPoint _shp 		id_spline_contour	 	id_pt_contour
					local id_pt_contour_svt = if id_pt_contour != pts_spline_contour.count then id_pt_contour + 1 else 1
-- 					local pt_contour_svt  	= getKnotPoint _shp 		id_spline_contour	 	id_pt_contour_svt
					
					local pt_contour_type 			= getKnotType 		_shp  id_spline_contour	 id_pt_contour
					local pt_contour_svt_type 	= getKnotType 		_shp  id_spline_contour	 id_pt_contour_svt
					
					if pt_contour_type != #corner or pt_contour_svt_type != #corner then (
						
						----- Interpolation  - adaptif ----------------------------					
						local longueur_segment 	= get_longueur_segment	_shp	id_spline_contour		id_pt_contour 
						local pos_courbe 			= 0
						local nbr_division 			= floor ( longueur_segment / precision_courbe)
						local increment_courbe 	= 1 / nbr_division
						
						local tangent					=	normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		0 )
						local tangent_derniere		= 	tangent
						
						append pt_result	( interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		0 )
						
						while pos_courbe < 1 do (
							
	-- 							debug "---# pos_courbe # " var:pos_courbe
							local pt_interpol 	= interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		pos_courbe
							tangent 				= normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		pos_courbe )
							
	-- 						debug "------------>	tangent  " var:tangent
							local dot_tangents = dot tangent tangent_derniere
							
	-- 						debug "------------>	dot_tangents" var:dot_tangents
							if dot_tangents <	dotmax_courbe do (
								tangent_derniere = tangent
								append pt_result	pt_interpol
							)
							pos_courbe	+= increment_courbe
							
						)
					) else append pt_result	pt_contour
-- 							)
-- 					) ---- fin case type -------------------
					
				)
				
				--- on met les points dans l'ordre	----------
				if not est_sensPositif 	pt_result 	 do
					pt_result = changer_sens		pt_result
				
				append result	pt_result
			)
			
			
			--- on recalle les points � la transform du shape ------------
			for shp in result do
				for pt in shp do
					pt += [10000,0,0]	---inverse _shp.transform
			
			---- on vire les points en ligne droite ----------
			result = nettoyer_points_inutiles	result
			
			result
		),
		
		
		
		
		
		
	------------------- INTERFACE -----------------------------------------------------------------------
	public
		
		fn interpoler_pts_from_shape  	_shp=( 
			
			local pts_shps = interpoler_shape 		_shp
			
			--- on les plaque sur z=0 -----
			for shp in pts_shps do	shp.z = 0
			
			pts_shps
		),
		
		
		------- le fonction  traingulation d'un polygone  ---------------------
		--- renvois le tableau des triangles decoup�s -------
		fn trianguler  _pts =(
			
-- 			debug "trianguler"
			local pts_poly 			= deepcopy _pts
			
			local result_triangles	= #()
			
			--------------- tant qu'il reste plus de trois point dans le polygone ------------------			
			while pts_poly.count >= 3 do (
-- 				debug "trianguler-------------------------------------------------" 
-- 				debug "	---->	triangle :" var:result_triangles.count
				
				-- on commence avec le point le plus a gauche du polygone--
				local id_pt_aTester 	= point_lePlusAGauche  pts_poly		
				
				-- le point d'avant ---
				local id_pt_avant 	= if id_pt_aTester == 1 	then	pts_poly.count 
																				else	id_pt_aTester - 1		
				-- et le point d'apr�s ---
				local id_pt_apres 	= if id_pt_aTester == pts_poly.count 	then	1
																									else	id_pt_aTester + 1
				--- Le triangle � tester ---
				local triangle_aTester = #(pts_poly[id_pt_avant], pts_poly[id_pt_aTester], pts_poly[id_pt_apres])
				
				
-- 				debug "--------->	triangle_aTester" var:triangle_aTester
				----- Puis on cherche parmis les points restants du polygone ceux qui seraient � l'interieur du trangle ----		
				local ids_pts_dansTriangle =#()		
				for i = 1 to pts_poly.count do(
					local pt_atester 				= pts_poly[i]
					local pt_dansTriangle 		= est_dansTriangle 	triangle_aTester[1]	 triangle_aTester[2]	 triangle_aTester[3]	  pt_atester
-- 					debug "		--------->	est_dansTriangle ?" var:pt_dansTriangle
					
					if pt_dansTriangle do append ids_pts_dansTriangle  i
				)
-- 				debug "--------->	ids_pts_dansTriangle" var:ids_pts_dansTriangle
				if ids_pts_dansTriangle.count > 0 then (
					
					
-- 					format "		************	On a un point dans un triangle !!! --> id:%		**************\n"  id_pt_aTester
					local pts_dansTriangle	=	for id_pt in ids_pts_dansTriangle collect pts_poly[id_pt]
-- 					debug "--------->	pts_dansTriangle" var:pts_dansTriangle
					
					---- si on en trouve : on cherche le plus �loign� de la 'diagonale' du triangle ----
					local IDpt_diagonal = 	point_lePlusLoinDuSegment  	pts_dansTriangle		triangle_aTester[3]		triangle_aTester[1]
					local IDpt_decoupe = 	ids_pts_dansTriangle[ IDpt_diagonal ]
					
-- 				debug "--------->	IDpt_diagonal" var:IDpt_diagonal
-- 				debug "--------->	IDpt_decoupe" var:IDpt_decoupe
					-- on decoupe le polygone en 2 avec la digonale entre ce dernier point et le point � tester --
					--- premier polygone d�coup� -------
					local IDsPts_poly1  = #(IDpt_decoupe)
					local pts_poly1  = #()
					local  i = boucler  pts_poly  (id_pt_aTester ) 
					while i 	!= IDpt_decoupe  do (
						append IDsPts_poly1		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly1 = for idPt in IDsPts_poly1 collect pts_poly[idPt]
					--- second polygone d�coup� -------
					local IDsPts_poly2  = #(id_pt_aTester)
					local pts_poly2  = #()
					local  i = boucler  pts_poly  (IDpt_decoupe ) 
					while i 	!= id_pt_aTester   do (
						append IDsPts_poly2		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly2 = for idPt in IDsPts_poly2 collect pts_poly[idPt]

					result_triangles += trianguler  pts_poly1
					result_triangles += trianguler  pts_poly2
					
					
					
					/* 
					sp = splineShape name:(Uniquename "decoupage poly 1 - ")
					addnewSpline sp
					for pt in pts_poly1 do		addknot sp 1 #corner #curve  pt
					close sp 1
					updateShape sp
					sp = splineShape name:(Uniquename "decoupage poly 2 - ")
					addnewSpline sp
					for pt in pts_poly2 do		addknot sp 1 #corner #curve  pt
					close sp 1
					updateShape sp
-- 						selectMore sp
					 */
					
					
					
					
					
					-- on vide les points de poly car on a lanc� la fonction recursivement sur les deux poly trouv�s, et on veut sortir de la boucle----
					pts_poly = #()
					
				) else (
					
					---- si on en trouve pas: on peut creer le triangle et retirer le point tester de la liste du polygone ----
					append 	result_triangles  triangle_aTester
					deleteItem pts_poly  id_pt_aTester
					
				)
				
			)  --- fin du while il ya plus de 3 pts dans le polygone ------
			
			result_triangles
			
		), --- fin fonction decoupage polygone ----------

		
		---- on entre une liste de listes de points  (nos differents shapes � analyser )------------
		---- renvois une liste des points avec fusion des shapes � trous en une seule liste pour cre�ation de face trou� ---------
		fn creer_hierarchie_booleens		 	_pts_shps 	=(
			
			---- on cherche les booleens --------------------
			local pts_results 	=  preparer_booleens 	_pts_shps
			
			pts_results
			
		)
	
		
			
	
)



cible 			= $Line001
pts_cible 	=	for i in 1 to numknots cible collect getknotPoint cible	1	i
popo = str_tmp ()
popo.get_aire_shape	pts_cible


triangle 	= $Line002
pts_tri 	= for i in 1 to numknots triangle collect getknotPoint triangle	1	i
popo.get_aire_triangle	pts_tri



ÿþC O N  
     _ c l k m o d e   =   x t a l 1   +   p l l 1 6 x  
     _ x i n f r e q   =   5 _ 0 0 0 _ 0 0 0  
 O B J                                                                     ' i n c l u d e   2   V i e w P o r t   o b j e c t s :  
   v p         :   " C o n d u i t "                                   ' t r a n s f e r s   d a t a   t o / f r o m   P C  
   q s         :   " Q u i c k S a m p l e "                               ' s a m p l e s   I N A   c o n t i n u o u s l y   i n   1   c o g -   u p   t o   2 0 M s p s  
 V A R  
     l o n g   s t a c k [ 2 0 ]  
     l o n g   s t a c k 2 [ 2 0 ]  
     l o n g   f r a m e [ 4 0 0 ]  
     l o n g   v 1 , o u t P , i n P , v 2 , d b , x o r x  
 C O N  
     S H L D   =   2 3   ' L o w   m e a n s   l o a d   i n .     H i g h   m e a n s   l o a d - o u t .  
     C L K   =   2 4     ' D a t a   s h i f t s   o n   a   p o s i t i v e   t r a n s i t i o n .  
     S E R   =   2 5     ' D a t a Z  
 P U B   m a i n  
     v p . r e g i s t e r ( q s . s a m p l e I N A ( @ f r a m e , 1 ) ) ' s a m p l e   I N A   i n t o   < f r a m e >   a r r a y  
     o p t i o n a l _ c o n f i g u r e _ v i e w p o r t  
     v p . c o n f i g ( s t r i n g ( " v a r : v 1 , v 2 , v 3 ( b a s e = 2 ) , d b ( b a s e = 2 ) , x o r x ( b a s e = 2 ) " ) )  
     v p . c o n f i g ( s t r i n g ( " s t a r t : d l l " ) )  
     v p . s h a r e ( @ o u t P , @ x o r x )                     ' s h a r e   v a r i a b l e  
 c o g n e w ( p o l l b o a r d ,   @ s t a c k )  
 c o g n e w ( d e l t a b o a r d ,   @ s t a c k 2 )      
      
      
 P U B   d e l t a b o a r d  
     d b   : =   0  
     r e p e a t  
         x o r x   : =   v 2   ^   d b  
         d b   : =   v 2  
  
 P U B   p o l l b o a r d  
     d i r a [ 1 2 ] ~ ~  
     d i r a [ 1 3 ] ~ ~  
     d i r a [ 1 4 ] ~ ~  
     d i r a [ S H L D ] ~ ~   ' W e   w r i t e   t h i s .  
     d i r a [ C L K ] ~ ~     ' W e   w r i t e   t h i s .  
     d i r a [ S E R ] ~       ' W e   r e a d   t h i s .  
  
     r e p e a t  
         o u t a [ 1 2 ] ~  
         o u t a [ 1 3 ] ~  
         o u t a [ 1 4 ] ~ ~  
         s i n g l e s c a n  
         o u t a [ 1 2 ] ~  
         o u t a [ 1 3 ] ~ ~  
         o u t a [ 1 4 ] ~  
         s i n g l e s c a n  
         o u t a [ 1 2 ] ~ ~  
         o u t a [ 1 3 ] ~  
         o u t a [ 1 4 ] ~  
         s i n g l e s c a n  
  
 P U B   s i n g l e s c a n  
       o u t a [ S H L D ] ~   ' L o a d   ' e m   u p !  
       o u t a [ C L K ] ~ ~   ' G e t   c l o c k   i n   c o r r e c t   p o s i t i o n   f o r . . .                                          
       o u t a [ S H L D ] ~ ~ ' C l o c k   t r a n s i t i o n s   n o w   s h i f t   d a t a .                                        
       v 1   : =   v 1   < <   1   +   i n a [ S E R ]   ' F i r s t   b i t   i s   a l r e a d y   i n   p o s i t i o n .  
       r e p e a t   ( 3 2 )                        
           o u t a [ C L K ] ~ ~                         ' T r a n s i t   u p   a n d   s h i f t                    
           v 1   : =   v 1   < <   1   +   i n a [ S E R ]   ' R e a d   b i t          
           o u t a [ C L K ] ~   ' D r o p   t h e   c l o c k   i n   p r e p a r a t i o n   f o r   n e x t   c y c l e            
       v 2   : =   v 1  
       v 1   : =   0  
      
 p u b   o p t i o n a l _ c o n f i g u r e _ v i e w p o r t      
     v p . c o n f i g ( s t r i n g ( " v a r : i o ( b i t s = [ c n t r [ 1 2 . . 1 4 , 2 3 . . 2 5 ] ] ) , v 1 , v 2 , v 3 ( b a s e = 2 ) " ) )  
     v p . c o n f i g ( s t r i n g ( " l s a : v i e w = i o , t i m e s c a l e = 1 m s , t r i g g e r = i o [ 2 3 ] r " ) )  
     v p . c o n f i g ( s t r i n g ( " s t a r t : l s a " ) )  
 
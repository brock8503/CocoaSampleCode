FasdUAS 1.101.10   ��   ��    k             l     ��������  ��  ��        l      �� 	 
��   	 � �

 <codex>
 <abstract>These are the AppleScripts called by the main program.  This file is compiled
 at build time into the file AttachedScripts.scpt.  We have added two new build
 phases to accomplish this.</abstract>
 </codex>
			
    
 �  � 
 
   < c o d e x > 
   < a b s t r a c t > T h e s e   a r e   t h e   A p p l e S c r i p t s   c a l l e d   b y   t h e   m a i n   p r o g r a m .     T h i s   f i l e   i s   c o m p i l e d 
   a t   b u i l d   t i m e   i n t o   t h e   f i l e   A t t a c h e d S c r i p t s . s c p t .     W e   h a v e   a d d e d   t w o   n e w   b u i l d 
   p h a s e s   t o   a c c o m p l i s h   t h i s . < / a b s t r a c t > 
   < / c o d e x > 
 	 	 	 
      l     ��������  ��  ��        l     ��������  ��  ��        l     ��������  ��  ��        l     ��������  ��  ��        l      ��  ��   �� AttachedScripts.applescript

These are the AppleScripts called by the main program.  This file is compiled
at build time into the file AttachedScripts.scpt.  We have added two new build
phases to accomplish this.


1. The first build phase executes this command:

    osacompile -d -o AttachedScripts.scpt AttachedScripts.applescript

This command compiles this source file 'AttachedScripts.applescript' saving the result
in the data fork of the file 'AttachedScripts.scpt'.


2. The second build phase simply copies both of the files 'AttachedScripts.scpt'
and 'AttachedScripts.applescript' into the final application's resources directory.


IMPORTANT:  I have noticed that you need to 'clean' the build
before it will copy the compiled versions of these files over
to the resources directory.  



Some interesting points to make here are:

(a) if at any time you want to reconfigure your application so that the scripts
do different things you can do so by editing this file and recompiling it to the
.scpt file using this command:
    osacompile -d -o AttachedScripts.scpt AttachedScripts.applescript

(b) everything here is datafork based and does not require any resource forks.  As
such,  it's easily transportable to other file systems.

(c) Recompiling this script file does not require recompilation of your main
program, but it can significantly enhance the configurability of your application.
As well, it can defer some design and interoperability decisions until later in
the development cycle.  Want to swap in a different app for some special task?
Just rewrite the script, your main program doesn't have to know about it...

(d) recompiling this script is even something that daring advanced users
with special requirements may want to do.

(c) because the main program only loads the precompiled
'AttachedScripts.scpt' your application does not bear any of the runtime
compilation costs that are involved.  From the application's point of
view, it's just 'Load and go...'.

     �  �   A t t a c h e d S c r i p t s . a p p l e s c r i p t 
 
 T h e s e   a r e   t h e   A p p l e S c r i p t s   c a l l e d   b y   t h e   m a i n   p r o g r a m .     T h i s   f i l e   i s   c o m p i l e d 
 a t   b u i l d   t i m e   i n t o   t h e   f i l e   A t t a c h e d S c r i p t s . s c p t .     W e   h a v e   a d d e d   t w o   n e w   b u i l d 
 p h a s e s   t o   a c c o m p l i s h   t h i s . 
 
 
 1 .   T h e   f i r s t   b u i l d   p h a s e   e x e c u t e s   t h i s   c o m m a n d : 
 
         o s a c o m p i l e   - d   - o   A t t a c h e d S c r i p t s . s c p t   A t t a c h e d S c r i p t s . a p p l e s c r i p t 
 
 T h i s   c o m m a n d   c o m p i l e s   t h i s   s o u r c e   f i l e   ' A t t a c h e d S c r i p t s . a p p l e s c r i p t '   s a v i n g   t h e   r e s u l t 
 i n   t h e   d a t a   f o r k   o f   t h e   f i l e   ' A t t a c h e d S c r i p t s . s c p t ' . 
 
 
 2 .   T h e   s e c o n d   b u i l d   p h a s e   s i m p l y   c o p i e s   b o t h   o f   t h e   f i l e s   ' A t t a c h e d S c r i p t s . s c p t ' 
 a n d   ' A t t a c h e d S c r i p t s . a p p l e s c r i p t '   i n t o   t h e   f i n a l   a p p l i c a t i o n ' s   r e s o u r c e s   d i r e c t o r y . 
 
 
 I M P O R T A N T :     I   h a v e   n o t i c e d   t h a t   y o u   n e e d   t o   ' c l e a n '   t h e   b u i l d 
 b e f o r e   i t   w i l l   c o p y   t h e   c o m p i l e d   v e r s i o n s   o f   t h e s e   f i l e s   o v e r 
 t o   t h e   r e s o u r c e s   d i r e c t o r y .     
 
 
 
 S o m e   i n t e r e s t i n g   p o i n t s   t o   m a k e   h e r e   a r e : 
 
 ( a )   i f   a t   a n y   t i m e   y o u   w a n t   t o   r e c o n f i g u r e   y o u r   a p p l i c a t i o n   s o   t h a t   t h e   s c r i p t s 
 d o   d i f f e r e n t   t h i n g s   y o u   c a n   d o   s o   b y   e d i t i n g   t h i s   f i l e   a n d   r e c o m p i l i n g   i t   t o   t h e 
 . s c p t   f i l e   u s i n g   t h i s   c o m m a n d : 
         o s a c o m p i l e   - d   - o   A t t a c h e d S c r i p t s . s c p t   A t t a c h e d S c r i p t s . a p p l e s c r i p t 
 
 ( b )   e v e r y t h i n g   h e r e   i s   d a t a f o r k   b a s e d   a n d   d o e s   n o t   r e q u i r e   a n y   r e s o u r c e   f o r k s .     A s 
 s u c h ,     i t ' s   e a s i l y   t r a n s p o r t a b l e   t o   o t h e r   f i l e   s y s t e m s . 
 
 ( c )   R e c o m p i l i n g   t h i s   s c r i p t   f i l e   d o e s   n o t   r e q u i r e   r e c o m p i l a t i o n   o f   y o u r   m a i n 
 p r o g r a m ,   b u t   i t   c a n   s i g n i f i c a n t l y   e n h a n c e   t h e   c o n f i g u r a b i l i t y   o f   y o u r   a p p l i c a t i o n . 
 A s   w e l l ,   i t   c a n   d e f e r   s o m e   d e s i g n   a n d   i n t e r o p e r a b i l i t y   d e c i s i o n s   u n t i l   l a t e r   i n 
 t h e   d e v e l o p m e n t   c y c l e .     W a n t   t o   s w a p   i n   a   d i f f e r e n t   a p p   f o r   s o m e   s p e c i a l   t a s k ? 
 J u s t   r e w r i t e   t h e   s c r i p t ,   y o u r   m a i n   p r o g r a m   d o e s n ' t   h a v e   t o   k n o w   a b o u t   i t . . . 
 
 ( d )   r e c o m p i l i n g   t h i s   s c r i p t   i s   e v e n   s o m e t h i n g   t h a t   d a r i n g   a d v a n c e d   u s e r s 
 w i t h   s p e c i a l   r e q u i r e m e n t s   m a y   w a n t   t o   d o . 
 
 ( c )   b e c a u s e   t h e   m a i n   p r o g r a m   o n l y   l o a d s   t h e   p r e c o m p i l e d 
 ' A t t a c h e d S c r i p t s . s c p t '   y o u r   a p p l i c a t i o n   d o e s   n o t   b e a r   a n y   o f   t h e   r u n t i m e 
 c o m p i l a t i o n   c o s t s   t h a t   a r e   i n v o l v e d .     F r o m   t h e   a p p l i c a t i o n ' s   p o i n t   o f 
 v i e w ,   i t ' s   j u s t   ' L o a d   a n d   g o . . . ' . 
 
      l     ��������  ��  ��        l     ��������  ��  ��        l     ��������  ��  ��         l     ��������  ��  ��      ! " ! l      �� # $��   #�� HookUpToRemoteMachine 
our app calls this script at application startup time.  In this handler
we present the url selection dialog allowing the user to select
a remote machine where the iTunes application we want to control
is running.  We store the remote machine address in the script's
property 'theRemoteURL' that is used by all of the other handlers
to direct commands to the iTunes app.  This handler returns the error
number if an error ocurred or 0 indicating sucess.     $ � % %�   H o o k U p T o R e m o t e M a c h i n e   
 o u r   a p p   c a l l s   t h i s   s c r i p t   a t   a p p l i c a t i o n   s t a r t u p   t i m e .     I n   t h i s   h a n d l e r 
 w e   p r e s e n t   t h e   u r l   s e l e c t i o n   d i a l o g   a l l o w i n g   t h e   u s e r   t o   s e l e c t 
 a   r e m o t e   m a c h i n e   w h e r e   t h e   i T u n e s   a p p l i c a t i o n   w e   w a n t   t o   c o n t r o l 
 i s   r u n n i n g .     W e   s t o r e   t h e   r e m o t e   m a c h i n e   a d d r e s s   i n   t h e   s c r i p t ' s 
 p r o p e r t y   ' t h e R e m o t e U R L '   t h a t   i s   u s e d   b y   a l l   o f   t h e   o t h e r   h a n d l e r s 
 t o   d i r e c t   c o m m a n d s   t o   t h e   i T u n e s   a p p .     T h i s   h a n d l e r   r e t u r n s   t h e   e r r o r 
 n u m b e r   i f   a n   e r r o r   o c u r r e d   o r   0   i n d i c a t i n g   s u c e s s .   "  & ' & l     ��������  ��  ��   '  ( ) ( j     �� *�� 0 theremoteurl theRemoteURL * m      + + � , ,   )  - . - l     ��������  ��  ��   .  / 0 / i     1 2 1 I      �������� .0 hookuptoremotemachine HookUpToRemoteMachine��  ��   2 Q     4 3 4 5 3 k    * 6 6  7 8 7 r     9 : 9 I   
���� ;
�� .sysochururl     ��� null��   ; �� <��
�� 
cusv < m    ��
�� essvesve��   : o      ���� 0 theurl theURL 8  = > = w     ? @ ? O     A B A l     C D E C r     F G F 1    ��
�� 
pVol G o      ���� 0 localvariable localVariable D 1 + try some command to verify the connection     E � H H V   t r y   s o m e   c o m m a n d   t o   v e r i f y   t h e   c o n n e c t i o n   B n     I J I 4    �� K
�� 
capp K m     L L � M M  i T u n e s J 4    �� N
�� 
mach N o    ���� 0 theurl theURL @�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��   >  O P O r     ' Q R Q o     !���� 0 theurl theURL R o      ���� 0 theremoteurl theRemoteURL P  S�� S L   ( * T T m   ( )����  ��   4 R      �� U V
�� .ascrerr ****      � **** U o      ���� 
0 errmsg   V �� W��
�� 
errn W o      ���� 0 errnum errNum��   5 L   2 4 X X o   2 3���� 0 errnum errNum 0  Y Z Y l     ��������  ��  ��   Z  [ \ [ l     ��������  ��  ��   \  ] ^ ] l      �� _ `��   _ ReportRemoteVolume 
This handler calls the remote iTunes application to obtain the current
volume setting - an integer value between 0 and 100.  NOTE:  this
is the volume setting inside of iTunes and it is not the same
as the output volume setting for the entire remote machine.     ` � a a0   R e p o r t R e m o t e V o l u m e   
 T h i s   h a n d l e r   c a l l s   t h e   r e m o t e   i T u n e s   a p p l i c a t i o n   t o   o b t a i n   t h e   c u r r e n t 
 v o l u m e   s e t t i n g   -   a n   i n t e g e r   v a l u e   b e t w e e n   0   a n d   1 0 0 .     N O T E :     t h i s 
 i s   t h e   v o l u m e   s e t t i n g   i n s i d e   o f   i T u n e s   a n d   i t   i s   n o t   t h e   s a m e 
 a s   t h e   o u t p u t   v o l u m e   s e t t i n g   f o r   t h e   e n t i r e   r e m o t e   m a c h i n e .   ^  b c b i    
 d e d I      �������� (0 reportremotevolume ReportRemoteVolume��  ��   e k      f f  g h g r      i j i m     ����   j o      ���� 0 	thevolume 	theVolume h  k l k w     m n m O     o p o r     q r q 1    ��
�� 
pVol r o      ���� 0 	thevolume 	theVolume p n     s t s 4    �� u
�� 
capp u m     v v � w w  i T u n e s t 4    �� x
�� 
mach x o    ���� 0 theremoteurl theRemoteURL n�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��   l  y�� y L     z z o    ���� 0 	thevolume 	theVolume��   c  { | { l     ��������  ��  ��   |  } ~ } l     ��������  ��  ��   ~   �  l      �� � ���   � SetRemoteVolume 
This handler calls the remote iTunes application to obtain the current
volume setting - an integer value between 0 and 100.  NOTE:  this
is the volume setting inside of iTunes and it is not the same
as the output volume setting for the entire remote machine.     � � � �*   S e t R e m o t e V o l u m e   
 T h i s   h a n d l e r   c a l l s   t h e   r e m o t e   i T u n e s   a p p l i c a t i o n   t o   o b t a i n   t h e   c u r r e n t 
 v o l u m e   s e t t i n g   -   a n   i n t e g e r   v a l u e   b e t w e e n   0   a n d   1 0 0 .     N O T E :     t h i s 
 i s   t h e   v o l u m e   s e t t i n g   i n s i d e   o f   i T u n e s   a n d   i t   i s   n o t   t h e   s a m e 
 a s   t h e   o u t p u t   v o l u m e   s e t t i n g   f o r   t h e   e n t i r e   r e m o t e   m a c h i n e .   �  � � � i     � � � I      �� ����� "0 setremotevolume SetRemoteVolume �  ��� � o      ���� 0 	newvolume 	newVolume��  ��   � w      � � � O     � � � r     � � � o    ���� 0 	newvolume 	newVolume � 1    ��
�� 
pVol � n     � � � 4   
 �� �
�� 
capp � m     � � � � �  i T u n e s � 4    
�� �
�� 
mach � o    	���� 0 theremoteurl theRemoteURL ��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��   �  � � � l     ��������  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l      �� � ���   � � � ReportRemotePlayerState 
This handler calls the remote iTunes application to obtain the current
status of the player - a list of seven elements including
playing (0 or 1), playlist, track, position, duration,
statusstr, and volume .      � � � ��   R e p o r t R e m o t e P l a y e r S t a t e   
 T h i s   h a n d l e r   c a l l s   t h e   r e m o t e   i T u n e s   a p p l i c a t i o n   t o   o b t a i n   t h e   c u r r e n t 
 s t a t u s   o f   t h e   p l a y e r   -   a   l i s t   o f   s e v e n   e l e m e n t s   i n c l u d i n g 
 p l a y i n g   ( 0   o r   1 ) ,   p l a y l i s t ,   t r a c k ,   p o s i t i o n ,   d u r a t i o n , 
 s t a t u s s t r ,   a n d   v o l u m e   .     �  � � � i     � � � I      �������� 20 reportremoteplayerstate ReportRemotePlayerState��  ��   � k     � � �  � � � r      � � � J     	 � �  � � � m     ����   �  � � � m     � � � � �   �  � � � m     � � � � �   �  � � � m    ����   �  � � � m    ����   �  � � � m     � � � � �  N o t   P l a y i n g �  ��� � m    ����  ��   � o      ���� 0 	theresult 	theResult �  � � � w    � � � � O    � � � � Z    � � ��� � � =   ! � � � 1    ��
�� 
pPlS � m     ��
�� ePlSkPSP � k   $ } � �  � � � l  $ $�� � ���   �   set up the status string    � � � � 2   s e t   u p   t h e   s t a t u s   s t r i n g �  � � � r   $ / � � � b   $ - � � � b   $ + � � � m   $ % � � � � �  P l a y i n g   ' � n   % * � � � 1   ( *��
�� 
pnam � 1   % (��
�� 
pTrk � m   + , � � � � �  '   b y   ' � o      ���� 0 	statusstr 	statusStr �  � � � r   0 ; � � � b   0 9 � � � b   0 7 � � � o   0 1���� 0 	statusstr 	statusStr � n   1 6 � � � 1   4 6��
�� 
pArt � 1   1 4��
�� 
pTrk � m   7 8 � � � � � " '   f r o m   p l a y l i s t   ' � o      ���� 0 	statusstr 	statusStr �  � � � r   < K � � � b   < I � � � b   < E � � � o   < =���� 0 	statusstr 	statusStr � n   = D � � � 1   B D��
�� 
pnam � 1   = B��
�� 
pPla � m   E H � � � � �  ' � o      ���� 0 	statusstr 	statusStr �  � � � l  L L� � ��   � #  put together the result list    � � � � :   p u t   t o g e t h e r   t h e   r e s u l t   l i s t �  � � � r   L ] � � � J   L [ � �  � � � m   L M�~�~  �  �  � n   M T 1   R T�}
�} 
pnam 1   M R�|
�| 
pPla  �{ n   T Y 1   W Y�z
�z 
pnam 1   T W�y
�y 
pTrk�{   � o      �x�x 0 	theresult 	theResult �  r   ^ p	 b   ^ n

 o   ^ _�w�w 0 	theresult 	theResult J   _ m  1   _ d�v
�v 
pPos �u n   d k 1   g k�t
�t 
pDur 1   d g�s
�s 
pTrk�u  	 o      �r�r 0 	theresult 	theResult �q r   q } b   q { o   q r�p�p 0 	theresult 	theResult J   r z  o   r s�o�o 0 	statusstr 	statusStr �n 1   s x�m
�m 
pVol�n   o      �l�l 0 	theresult 	theResult�q  ��   � r   � � J   � �  m   � ��k�k    !  m   � �"" �##  ! $%$ m   � �&& �''  % ()( m   � ��j�j  ) *+* m   � ��i�i  + ,-, m   � �.. �//  N o t   P l a y i n g- 0�h0 1   � ��g
�g 
pVol�h   o      �f�f 0 	theresult 	theResult � n    121 4    �e3
�e 
capp3 m    44 �55  i T u n e s2 4    �d6
�d 
mach6 o    �c�c 0 theremoteurl theRemoteURL ��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��   � 7�b7 L   � �88 o   � ��a�a 0 	theresult 	theResult�b   � 9:9 l     �`�_�^�`  �_  �^  : ;<; l     �]�\�[�]  �\  �[  < =>= l      �Z?@�Z  ? � � GongCurrentTrack is called when the user clicks on the
gong button.  This handler disables the track that is currently
playing and skips ahead to the next track.  If the player is not
playing, this handler does nothing.     @ �AA�   G o n g C u r r e n t T r a c k   i s   c a l l e d   w h e n   t h e   u s e r   c l i c k s   o n   t h e 
 g o n g   b u t t o n .     T h i s   h a n d l e r   d i s a b l e s   t h e   t r a c k   t h a t   i s   c u r r e n t l y 
 p l a y i n g   a n d   s k i p s   a h e a d   t o   t h e   n e x t   t r a c k .     I f   t h e   p l a y e r   i s   n o t 
 p l a y i n g ,   t h i s   h a n d l e r   d o e s   n o t h i n g .    > BCB i    DED I      �Y�X�W�Y $0 gongcurrenttrack GongCurrentTrack�X  �W  E w     *FGF O    *HIH Z    )JK�V�UJ =   LML 1    �T
�T 
pPlSM m    �S
�S ePlSkPSPK k    %NN OPO r    QRQ m    �R
�R boovfalsR n      STS 1    �Q
�Q 
enblT 1    �P
�P 
pTrkP U�OU I    %�N�M�L
�N .hookNextnull        null�M  �L  �O  �V  �U  I n    VWV 4   
 �KX
�K 
cappX m    YY �ZZ  i T u n e sW 4    
�J[
�J 
mach[ o    	�I�I 0 theremoteurl theRemoteURLG�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  C \]\ l     �H�G�F�H  �G  �F  ] ^_^ l     �E�D�C�E  �D  �C  _ `a` l      �Bbc�B  b � � SwitchRemotePlayerState is called when the user clicks on the
play/pause button.  This routine simply turns the remote player on
or off.     c �dd   S w i t c h R e m o t e P l a y e r S t a t e   i s   c a l l e d   w h e n   t h e   u s e r   c l i c k s   o n   t h e 
 p l a y / p a u s e   b u t t o n .     T h i s   r o u t i n e   s i m p l y   t u r n s   t h e   r e m o t e   p l a y e r   o n 
 o r   o f f .    a efe i    ghg I      �Ai�@�A 20 switchremoteplayerstate SwitchRemotePlayerStatei j�?j o      �>�> 0 newstate newState�?  �@  h w     $klk O    $mnm Z    #op�=qo l   r�<�;r =   sts o    �:�: 0 newstate newStatet m    �9�9 �<  �;  p I   �8�7�6
�8 .hookPlaynull    ��� obj �7  �6  �=  q I   #�5�4�3
�5 .hookPausnull        null�4  �3  n n    uvu 4   
 �2w
�2 
cappw m    xx �yy  i T u n e sv 4    
�1z
�1 
machz o    	�0�0 0 theremoteurl theRemoteURLl�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  f {|{ l     �/�.�-�/  �.  �-  | }~} l     �,�+�*�,  �+  �*  ~ � l      �)���)  � � ~ GoToNextTrack is called when the user clicks on the
skip ahead button.  This routine advances the player to the
next track.     � ��� �   G o T o N e x t T r a c k   i s   c a l l e d   w h e n   t h e   u s e r   c l i c k s   o n   t h e 
 s k i p   a h e a d   b u t t o n .     T h i s   r o u t i n e   a d v a n c e s   t h e   p l a y e r   t o   t h e 
 n e x t   t r a c k .    � ��� i    ��� I      �(�'�&�( 0 gotonexttrack GoToNextTrack�'  �&  � w     ��� O    ��� I   �%�$�#
�% .hookNextnull        null�$  �#  � n    ��� 4   
 �"�
�" 
capp� m    �� ���  i T u n e s� 4    
�!�
�! 
mach� o    	� �  0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  � ��� l     ����  �  �  � ��� l     ����  �  �  � ��� l      ����  � � � GoToPreviousTrack is called when the user clicks on the
skip back button.  This routine asks the player to go back
to the previous track.     � ���   G o T o P r e v i o u s T r a c k   i s   c a l l e d   w h e n   t h e   u s e r   c l i c k s   o n   t h e 
 s k i p   b a c k   b u t t o n .     T h i s   r o u t i n e   a s k s   t h e   p l a y e r   t o   g o   b a c k 
 t o   t h e   p r e v i o u s   t r a c k .    � ��� i    "��� I      ���� &0 gotoprevioustrack GoToPreviousTrack�  �  � w     ��� O    ��� I   ���
� .hookPrevnull        null�  �  � n    ��� 4   
 ��
� 
capp� m    �� ���  i T u n e s� 4    
��
� 
mach� o    	�� 0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  � ��� l     ����  �  �  � ��� l     ���
�  �  �
  � ��� l      �	���	  � � � GetPlaylistListing is called during program startup to retrieve
a list of the names of all of all of the playlists on the remote machine.     � ���   G e t P l a y l i s t L i s t i n g   i s   c a l l e d   d u r i n g   p r o g r a m   s t a r t u p   t o   r e t r i e v e 
 a   l i s t   o f   t h e   n a m e s   o f   a l l   o f   a l l   o f   t h e   p l a y l i s t s   o n   t h e   r e m o t e   m a c h i n e .    � ��� i   # &��� I      ���� (0 getplaylistlisting GetPlaylistListing�  �  � k     !�� ��� r     ��� J     ��  � o      �� 0 namelist nameList� ��� w    ��� O    ��� r    ��� e    �� n    ��� 1    �
� 
pnam� 2    �
� 
cPly� o      �� 0 namelist nameList� n    ��� 4    � �
�  
capp� m    �� ���  i T u n e s� 4    ���
�� 
mach� o   	 ���� 0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  � ���� L    !�� o     ���� 0 namelist nameList��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l      ������  � � � PlayTrackFromPlaylist is when the user double clicks on a track name
in the track list.  This handler receives a playlist name and the name of
the track and it asks the player to play that track.    � ����   P l a y T r a c k F r o m P l a y l i s t   i s   w h e n   t h e   u s e r   d o u b l e   c l i c k s   o n   a   t r a c k   n a m e 
 i n   t h e   t r a c k   l i s t .     T h i s   h a n d l e r   r e c e i v e s   a   p l a y l i s t   n a m e   a n d   t h e   n a m e   o f 
 t h e   t r a c k   a n d   i t   a s k s   t h e   p l a y e r   t o   p l a y   t h a t   t r a c k .  � ��� i   ' *��� I      ������� .0 playtrackfromplaylist PlayTrackFromPlaylist� ��� o      ���� 0 playlistname playlistName� ���� o      ���� 0 	trackname 	trackName��  ��  � w     .��� O    .��� O    -��� O    ,��� O    +��� I  % *������
�� .hookPlaynull    ��� obj ��  ��  � 4    "���
�� 
cTrk� o     !���� 0 	trackname 	trackName� 4    ���
�� 
cPly� o    ���� 0 playlistname playlistName� 4    ���
�� 
cSrc� m    �� ���  L i b r a r y� n    ��� 4   
 ���
�� 
capp� m    �� ���  i T u n e s� 4    
���
�� 
mach� o    	���� 0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l      ������  � � � GetPlaylistTracks is called when ever the user clicks on a new playlist
name in the list of displayed playlists.  Here we return a list containing
all of the names of the tracks in the selected playlist.    � ����   G e t P l a y l i s t T r a c k s   i s   c a l l e d   w h e n   e v e r   t h e   u s e r   c l i c k s   o n   a   n e w   p l a y l i s t 
 n a m e   i n   t h e   l i s t   o f   d i s p l a y e d   p l a y l i s t s .     H e r e   w e   r e t u r n   a   l i s t   c o n t a i n i n g 
 a l l   o f   t h e   n a m e s   o f   t h e   t r a c k s   i n   t h e   s e l e c t e d   p l a y l i s t .  � ��� i   + .� � I      ������ &0 getplaylisttracks GetPlaylistTracks �� o      ���� 0 playlistname playlistName��  ��    k     >  r      J     ����   o      ���� 0 	thetracks 	theTracks 	 Q    ;

 w    1 O   
 1 O    0 O    / r   & . e   & , n   & , 1   ) +��
�� 
pnam 2   & )��
�� 
cTrk o      ���� 0 	thetracks 	theTracks 4    #��
�� 
cPly o   ! "���� 0 playlistname playlistName 4    ��
�� 
cSrc m     �  L i b r a r y n   
  4    �� 
�� 
capp  m    !! �""  i T u n e s 4   
 ��#
�� 
mach# o    ���� 0 theremoteurl theRemoteURL�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��   R      ������
�� .ascrerr ****      � ****��  ��   L   9 ;$$ o   9 :���� 0 	thetracks 	theTracks	 %��% L   < >&& o   < =���� 0 	thetracks 	theTracks��  � '(' l     ��������  ��  ��  ( )*) l     ��������  ��  ��  * +,+ l      ��-.��  - � | GetPlaylistShuffle returns an integer value (0 or 1) reflecting
the status of the shuffle setting for the named playlist.     . �// �   G e t P l a y l i s t S h u f f l e   r e t u r n s   a n   i n t e g e r   v a l u e   ( 0   o r   1 )   r e f l e c t i n g 
 t h e   s t a t u s   o f   t h e   s h u f f l e   s e t t i n g   f o r   t h e   n a m e d   p l a y l i s t .    , 010 i   / 2232 I      ��4���� (0 getplaylistshuffle GetPlaylistShuffle4 5��5 o      ���� 0 playlistname playlistName��  ��  3 k     866 787 r     9:9 m     ����  : o      ����  0 shufflesetting shuffleSetting8 ;<; w    5=>= O    5?@? O    4ABA O    3CDC Z   " 2EF��GE 1   " &��
�� 
pShfF r   ) ,HIH m   ) *���� I o      ����  0 shufflesetting shuffleSetting��  G r   / 2JKJ m   / 0����  K o      ����  0 shufflesetting shuffleSettingD 4    ��L
�� 
cPlyL o    ���� 0 playlistname playlistNameB 4    ��M
�� 
cSrcM m    NN �OO  L i b r a r y@ n    PQP 4    ��R
�� 
cappR m    SS �TT  i T u n e sQ 4    ��U
�� 
machU o    ���� 0 theremoteurl theRemoteURL>�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  < V��V L   6 8WW o   6 7����  0 shufflesetting shuffleSetting��  1 XYX l     ��������  ��  ��  Y Z[Z l     ��������  ��  ��  [ \]\ l      ��^_��  ^ � � SetPlaylistShuffle changes the current shuffle setting for
the named playlist to shuffleSetting.  shuffleSetting should
be an integer value of either 0 (for off) or 1 (for on).    _ �``d   S e t P l a y l i s t S h u f f l e   c h a n g e s   t h e   c u r r e n t   s h u f f l e   s e t t i n g   f o r 
 t h e   n a m e d   p l a y l i s t   t o   s h u f f l e S e t t i n g .     s h u f f l e S e t t i n g   s h o u l d 
 b e   a n   i n t e g e r   v a l u e   o f   e i t h e r   0   ( f o r   o f f )   o r   1   ( f o r   o n ) .  ] aba i   3 6cdc I      ��e���� (0 setplaylistshuffle SetPlaylistShufflee fgf o      ���� 0 playlistname playlistNameg h��h o      ����  0 shufflesetting shuffleSetting��  ��  d w     4iji O    4klk O    3mnm O    2opo Z    1qr��sq =   !tut o    ����  0 shufflesetting shuffleSettingu m     ���� r r   $ )vwv m   $ %��
�� boovtruew 1   % (��
�� 
pShf��  s r   , 1xyx m   , -��
�� boovfalsy 1   - 0��
�� 
pShfp 4    ��z
�� 
cPlyz o    ���� 0 playlistname playlistNamen 4    ��{
�� 
cSrc{ m    || �}}  L i b r a r yl n    ~~ 4   
 ���
�� 
capp� m    �� ���  i T u n e s 4    
���
�� 
mach� o    	���� 0 theremoteurl theRemoteURLj�                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  b ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� l      ������  � � � GetPlaylistRepeat returns an integer value of 0, for repeat off,
1, for repeat all, or 2, for repeat one, reflecting the state of
the repeat setting for the named playlist.      � ���`   G e t P l a y l i s t R e p e a t   r e t u r n s   a n   i n t e g e r   v a l u e   o f   0 ,   f o r   r e p e a t   o f f , 
 1 ,   f o r   r e p e a t   a l l ,   o r   2 ,   f o r   r e p e a t   o n e ,   r e f l e c t i n g   t h e   s t a t e   o f 
 t h e   r e p e a t   s e t t i n g   f o r   t h e   n a m e d   p l a y l i s t .      � ��� i   7 :��� I      ������� &0 getplaylistrepeat GetPlaylistRepeat� ���� o      ���� 0 playlistname playlistName��  ��  � k     S�� ��� r     ��� m     ����  � o      ���� 0 repeatsetting repeatSetting� ��� w    P��� O    P��� O    O��� O    N��� Z   " M������ l  " '������ =  " '��� 1   " %��
�� 
pRpt� m   % &��
�� eRptkRpO��  ��  � r   * -��� m   * +����  � o      ���� 0 repeatsetting repeatSetting� ��� l  0 5����� =  0 5��� 1   0 3�~
�~ 
pRpt� m   3 4�}
�} eRptkAll��  �  � ��� r   8 ;��� m   8 9�|�| � o      �{�{ 0 repeatsetting repeatSetting� ��� l  > C��z�y� =  > C��� 1   > A�x
�x 
pRpt� m   A B�w
�w eRptkRp1�z  �y  � ��v� r   F I��� m   F G�u�u � o      �t�t 0 repeatsetting repeatSetting�v  ��  � 4    �s�
�s 
cPly� o    �r�r 0 playlistname playlistName� 4    �q�
�q 
cSrc� m    �� ���  L i b r a r y� n    ��� 4    �p�
�p 
capp� m    �� ���  i T u n e s� 4    �o�
�o 
mach� o    �n�n 0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  � ��m� L   Q S�� o   Q R�l�l 0 repeatsetting repeatSetting�m  � ��� l     �k�j�i�k  �j  �i  � ��� l     �h�g�f�h  �g  �f  � ��� l      �e���e  � � � SetPlaylistRepeat is called to change the repeat setting
for the named playlist.  repeatSetting should be a either
0, 1 or 2 representing 'repeat off', 'repeat all', or 
'repeat one' respectively.     � ����   S e t P l a y l i s t R e p e a t   i s   c a l l e d   t o   c h a n g e   t h e   r e p e a t   s e t t i n g 
 f o r   t h e   n a m e d   p l a y l i s t .     r e p e a t S e t t i n g   s h o u l d   b e   a   e i t h e r 
 0 ,   1   o r   2   r e p r e s e n t i n g   ' r e p e a t   o f f ' ,   ' r e p e a t   a l l ' ,   o r   
 ' r e p e a t   o n e '   r e s p e c t i v e l y .    � ��� i   ; >��� I      �d��c�d &0 setplaylistrepeat SetPlaylistRepeat� ��� o      �b�b 0 playlistname playlistName� ��a� o      �`�` 0 repeatsetting repeatSetting�a  �c  � w     L��� O    L��� O    K��� O    J��� Z    I����_� l   !��^�]� =   !��� o    �\�\ 0 repeatsetting repeatSetting� m     �[�[  �^  �]  � r   $ )��� m   $ %�Z
�Z eRptkRpO� 1   % (�Y
�Y 
pRpt� ��� l  , /��X�W� =  , /��� o   , -�V�V 0 repeatsetting repeatSetting� m   - .�U�U �X  �W  � ��� r   2 7��� m   2 3�T
�T eRptkAll� 1   3 6�S
�S 
pRpt� ��� l  : =��R�Q� =  : =��� o   : ;�P�P 0 repeatsetting repeatSetting� m   ; <�O�O �R  �Q  � ��N� r   @ E��� m   @ A�M
�M eRptkRp1� 1   A D�L
�L 
pRpt�N  �_  � 4    �K�
�K 
cPly� o    �J�J 0 playlistname playlistName� 4    �I�
�I 
cSrc� m    �� ���  L i b r a r y� n    ��� 4   
 �H�
�H 
capp� m       �  i T u n e s� 4    
�G
�G 
mach o    	�F�F 0 theremoteurl theRemoteURL��                                                                                  hook  alis    L  Snow Leopard               �%aH+    =
iTunes.app                                                      ���d��        ����  	                Applications    �%h�      �d�      =  $Snow Leopard:Applications:iTunes.app   
 i T u n e s . a p p    S n o w   L e o p a r d  Applications/iTunes.app   / ��  �  l     �E�D�C�E  �D  �C    l     �B�A�@�B  �A  �@   �? l     �>�=�<�>  �=  �<  �?       �; +	
�;   �:�9�8�7�6�5�4�3�2�1�0�/�.�-�,�+�: 0 theremoteurl theRemoteURL�9 .0 hookuptoremotemachine HookUpToRemoteMachine�8 (0 reportremotevolume ReportRemoteVolume�7 "0 setremotevolume SetRemoteVolume�6 20 reportremoteplayerstate ReportRemotePlayerState�5 $0 gongcurrenttrack GongCurrentTrack�4 20 switchremoteplayerstate SwitchRemotePlayerState�3 0 gotonexttrack GoToNextTrack�2 &0 gotoprevioustrack GoToPreviousTrack�1 (0 getplaylistlisting GetPlaylistListing�0 .0 playtrackfromplaylist PlayTrackFromPlaylist�/ &0 getplaylisttracks GetPlaylistTracks�. (0 getplaylistshuffle GetPlaylistShuffle�- (0 setplaylistshuffle SetPlaylistShuffle�, &0 getplaylistrepeat GetPlaylistRepeat�+ &0 setplaylistrepeat SetPlaylistRepeat	 �* 2�)�(�'�* .0 hookuptoremotemachine HookUpToRemoteMachine�)  �(   �&�%�$�#�& 0 theurl theURL�% 0 localvariable localVariable�$ 
0 errmsg  �# 0 errnum errNum 
�"�!�  @�� L��
�" 
cusv
�! essvesve
�  .sysochururl     ��� null
� 
mach
� 
capp
� 
pVol� 
0 errmsg   ���
� 
errn� 0 errnum errNum�  �' 5 ,*��l E�O�Z*�/��/ *�,E�UO�Ec   OjW 	X  	�
 � e���� (0 reportremotevolume ReportRemoteVolume�  �   �� 0 	thevolume 	theVolume  n�� v�
� 
mach
� 
capp
� 
pVol� jE�O�Z*�b   /��/ *�,E�UO� � ����� "0 setremotevolume SetRemoteVolume� ��   �� 0 	newvolume 	newVolume�   �
�
 0 	newvolume 	newVolume  ��	� ��
�	 
mach
� 
capp
� 
pVol� �Z*�b   /��/ �*�,FU � ��� !�� 20 reportremoteplayerstate ReportRemotePlayerState�  �    ��� 0 	theresult 	theResult� 0 	statusstr 	statusStr!  � � ��  �����4���� ����� ��� ��� �������"&.�  
�� 
mach
�� 
capp
�� 
pPlS
�� ePlSkPSP
�� 
pTrk
�� 
pnam
�� 
pArt
�� 
pPla
�� 
pPos
�� 
pDur
�� 
pVol� �j��jj�j�vE�O�Z*�b   /��/ {*�,�  ^�*�,�,%�%E�O�*�,�,%�%E�O�*a ,�,%a %E�Ok*a ,�,*�,�,mvE�O�*a ,*�,a ,lv%E�O��*a ,lv%E�Y ja a jja *a ,�vE�UO� ��E����"#���� $0 gongcurrenttrack GongCurrentTrack��  ��  "  # 	G����Y����������
�� 
mach
�� 
capp
�� 
pPlS
�� ePlSkPSP
�� 
pTrk
�� 
enbl
�� .hookNextnull        null�� +�Z*�b   /��/ *�,�  f*�,�,FO*j Y hU ��h����$%���� 20 switchremoteplayerstate SwitchRemotePlayerState�� ��&�� &  ���� 0 newstate newState��  $ ���� 0 newstate newState% l����x����
�� 
mach
�� 
capp
�� .hookPlaynull    ��� obj 
�� .hookPausnull        null�� %�Z*�b   /��/ �k  
*j Y *j U �������'(���� 0 gotonexttrack GoToNextTrack��  ��  '  ( ��������
�� 
mach
�� 
capp
�� .hookNextnull        null�� �Z*�b   /��/ *j U �������)*���� &0 gotoprevioustrack GoToPreviousTrack��  ��  )  * ��������
�� 
mach
�� 
capp
�� .hookPrevnull        null�� �Z*�b   /��/ *j U �������+,���� (0 getplaylistlisting GetPlaylistListing��  ��  + ���� 0 namelist nameList, ����������
�� 
mach
�� 
capp
�� 
cPly
�� 
pnam�� "jvE�O�Z*�b   /��/ 
*�-�,EE�UO� �������-.���� .0 playtrackfromplaylist PlayTrackFromPlaylist�� ��/�� /  ������ 0 playlistname playlistName�� 0 	trackname 	trackName��  - ������ 0 playlistname playlistName�� 0 	trackname 	trackName. 	���������������
�� 
mach
�� 
capp
�� 
cSrc
�� 
cPly
�� 
cTrk
�� .hookPlaynull    ��� obj �� /�Z*�b   /��/ *��/ *�/ *�/ *j UUUU �� ����01���� &0 getplaylisttracks GetPlaylistTracks�� ��2�� 2  ���� 0 playlistname playlistName��  0 ������ 0 playlistname playlistName�� 0 	thetracks 	theTracks1 ����!������������
�� 
mach
�� 
capp
�� 
cSrc
�� 
cPly
�� 
cTrk
�� 
pnam��  ��  �� ?jvE�O .�Z*�b   /��/ *��/ *�/ 
*�-�,EE�UUUW 	X 	 
�O� ��3����34���� (0 getplaylistshuffle GetPlaylistShuffle�� ��5�� 5  ���� 0 playlistname playlistName��  3 ������ 0 playlistname playlistName��  0 shufflesetting shuffleSetting4 >����S��N����
�� 
mach
�� 
capp
�� 
cSrc
�� 
cPly
�� 
pShf�� 9jE�O�Z*�b   /��/ "*��/ *�/ *�,E kE�Y jE�UUUO� ��d����67���� (0 setplaylistshuffle SetPlaylistShuffle�� ��8�� 8  ������ 0 playlistname playlistName��  0 shufflesetting shuffleSetting��  6 ������ 0 playlistname playlistName��  0 shufflesetting shuffleSetting7 j�������|����
�� 
mach
�� 
capp
�� 
cSrc
�� 
cPly
�� 
pShf�� 5�Z*�b   /��/ %*��/ *�/ �k  
e*�,FY f*�,FUUU �������9:���� &0 getplaylistrepeat GetPlaylistRepeat�� ��;�� ;  ���� 0 playlistname playlistName��  9 ������ 0 playlistname playlistName�� 0 repeatsetting repeatSetting: �����������������~
�� 
mach
�� 
capp
�� 
cSrc
�� 
cPly
�� 
pRpt
�� eRptkRpO
� eRptkAll
�~ eRptkRp1�� TjE�O�Z*�b   /��/ =*��/ 5*�/ -*�,�  jE�Y *�,�  kE�Y *�,�  lE�Y hUUUO� �}��|�{<=�z�} &0 setplaylistrepeat SetPlaylistRepeat�| �y>�y >  �x�w�x 0 playlistname playlistName�w 0 repeatsetting repeatSetting�{  < �v�u�v 0 playlistname playlistName�u 0 repeatsetting repeatSetting= ��t�s �r��q�p�o�n�m
�t 
mach
�s 
capp
�r 
cSrc
�q 
cPly
�p eRptkRpO
�o 
pRpt
�n eRptkAll
�m eRptkRp1�z M�Z*�b   /��/ =*��/ 5*�/ -�j  
�*�,FY �k  
�*�,FY �l  
�*�,FY hUUUascr  ��ޭ
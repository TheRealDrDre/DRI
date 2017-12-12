;;;; =================================================================
;;;; DRI
;;;; -----------------------------------------------------------------
;;;; An ACT-R model for the DRI experiment by Patrick J. Rice.
;;;; -----------------------------------------------------------------
;;;; General idea is to have different models
;;;; 
;;;; Implementing TMS:
;;;; TMS is implemented by adding 500ms to the execution time
;;;; of any production that could be targeted. Productions encode
;;;; control, so the assumption is legit.
;;;; (Potentially, all of the prods could be tested!!!).
;;;;
;;;; to do:
;;;; Add a DM phase, in which the model decides whether it is the case
;;;; to respond or to invert.
;;;;



(clear-all)
(define-model dri

(sgp :auto-attend t
     :esc t)

(chunk-type parity-fact number parity)

(chunk-type (dri-object (:include visual-object))
	    kind location)

(chunk-type wm rule action kind)

(chunk-type trial step)

(add-dm (even isa chunk) (odd isa chunk)
	(a isa chunk) (b isa chunk)
	(processing isa chunk) (respond isa chunk)
	;;(one isa chunk) (two isa chunk)
	;;(three isa chunk) (four isa chunk)
	;;(five isa chunk) (six isa chunk)
	;;(seven isa chunk) (eight isa chunk)
	;;(nine isa chunk)
	;; Basic structures
	(stimulus isa chunk)
	(rule isa chunk)
	(screen isa chunk)
	(pause isa chunk)
	(option isa chunk)
	(target isa chunk)
	(action isa chunk)
	(instructions isa chunk)
	(can-proceed isa chunk)
	(mist-infer isa chunk)

	;; Parity
	(one-odd isa parity-fact
		 number 1 parity odd)
	(two-even isa parity-fact
		 number 2 parity even)
	(three-odd isa parity-fact
		 number 3 parity odd)
	(four-even isa parity-fact
		 number 4 parity even)
	(five-odd isa parity-fact
		 number 5 parity odd)
	(six-even isa parity-fact
		 number 6 parity even)
	(seven-odd isa parity-fact
		   number 7 parity odd)
	(eight-even isa parity-fact
		    number 8 parity even)
	(nine-odd isa parity-fact
		  number 9 parity odd))

;;; VISUAL PROCESSING

(p look-at-screen
   "Looks at the screen if nothing to process" 
   ?visual>
     state free
     buffer empty
   ?visual-location>
     state free
     buffer empty
==>
   +visual-location>
     kind screen
)

(p recover-from-visual-change
   "If the visual scene changes abrubtly, re-encode the screen"
   ?visual>
     error t
==>
   +visual-location>
     kind screen
)

;;; RULE ENCODING

(p look-at-rule
   ?visual>
   - state error
     state free

   =visual>
     kind screen
==>
   +visual-location>
     kind rule
)

(p encode-rule
   ?visual>
     state free
   ?imaginal>
     state free
     buffer empty
   =visual>
     kind rule
     value =RULE
==>
  +imaginal>
     isa wm
     kind instructions
     rule =RULE

  +goal>
     isa trial
     step processing
     
  =visual>
)

(p look-at-action
   ?visual>
     state free

   ?imaginal>
     state free
     
   =visual>
     kind rule

   =imaginal>
   - rule nil
     action nil
==>
   =imaginal>     
   +visual-location>
     kind action  
)


(p encode-action
   ?visual>
     state free

   ?imaginal>
     state free

   =visual>
     kind action
     value =ACTION
    
   =imaginal>
   - rule nil
     action nil
==>
  =visual>

  *imaginal>
     isa wm
     action =ACTION
)

(p move-on
   =imaginal>
   - rule nil
   - action nil

   =visual>
     kind action
   
   ?imaginal>
     state free

   ?manual>
     preparation free
     processor free
     execution free

==>
   =imaginal>

   +manual>
     isa punch
     hand right
     finger index
)

;;; TARGET PROCESSING

(p look-at-target
   ?visual>
     state free

   =visual>
     value stimulus
==>
   +visual-location>
     kind target
)


(p retrieve-parity
   ?visual>
     state free

   =imaginal>
     kind instructions
   - rule nil
     
   ?retrieval>
     state free
     buffer empty
   
   =visual>
     kind target
     value =NUM

==>
  =visual>
  =imaginal>
  +retrieval>
    isa parity-fact
    number =NUM
)

;;; RESPONSE

;;; RESPONSE for FINGERS

(p respond-instructed-finger
   =imaginal>
     rule =RULE
     action =FINGER
   - action A
   - action B  

   =visual>
     kind target
     value =NUM
     
   =retrieval>
     isa parity-fact
     number =NUM
     parity =RULE
    
   ?manual>
     preparation free
     processor free
     execution free

==>
   +manual>
     isa punch
     hand right
     finger =FINGER
)

(p respond-inferred-finger-middle
   =imaginal>
     rule =RULE
     action index
   - action A
   - action B  

   =visual>
     kind target
     value =NUM
     
   =retrieval>
     isa parity-fact
     number =NUM
   - parity =RULE
    
   ?manual>
     preparation free
     processor free
     execution free

==>
   +manual>
     isa punch
     hand right
     finger middle
)

(p respond-inferred-finger-index
   =imaginal>
     rule =RULE
     action middle
   - action A
   - action B  

   =visual>
     kind target
     value =NUM
     
   =retrieval>
     isa parity-fact
     number =NUM
   - parity =RULE
    
   ?manual>
     preparation free
     processor free
     execution free

==>
   +manual>
     isa punch
     hand right
     finger index
)


;;; RESPONSE FOR SYMBOLS

(p find-instructed-symbol
   =imaginal>
     action =SYMBOL
   - action index
   - action middle  

   =visual>
     kind target
     
   ?retrieval>
     buffer full
    
   ?visual>
     state free
==>
   =imaginal>
   +visual-location>
     kind option
     value =SYMBOL
)

(p decide-instructed-symbol
   =imaginal>
     rule =PARITY

   =goal>
     step processing
   
   =visual>
     kind option
     
   =retrieval>
     isa parity-fact
     parity =PARITY

   ?visual>
     state free
==>
   *goal>     
     step respond
   =visual>
)

(p decide-inferred-symbol
   =imaginal>
     rule =PARITY

   =goal>
     step processing
   
   =visual>
     kind option
     value =OPTION
     
   =retrieval>
     isa parity-fact
   - parity =PARITY

   ?visual>
     state free
==>
   +visual-location>
     kind option
   - value =OPTION
    
   *goal>     
     step respond

)

(p respond-symbol-left
   =goal>
     step respond

   =visual>
     kind option
     location left
     
   ?manual>
     preparation free
     processor free
     execution free

==>
  +manual>
     isa punch
     hand right
     finger index
)


(p respond-symbol-right
   =goal>
     step respond

   =visual>
     kind option
     location right
     
   ?manual>
     preparation free
     processor free
     execution free

==>
  +manual>
     isa punch
     hand right
     finger middle
)



) ;; end of model

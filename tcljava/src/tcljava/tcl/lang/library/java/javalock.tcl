# javaLock.tcl --
#
# Maintain an internal pointer to java objects to control 
# when the object is garbage collected.
#
# When a variable references a Java object, the internal rep
# points to a ReflectObject that contains the object.  If an
# operation is performed on the variable that alters the 
# internal rep (e.g. llength $x), the ReflectObject is 
# destroied and the Java object is garbage collected.  By 
# maintaining an internal pointer to the object, the
# java::lock and java::unlock commands can prevent the unwanted
# garbage collection of the Java object. 
#
# Copyright (c) 1998 by Sun Microsystems, Inc.
#
# RCS: @(#) $Id: javalock.tcl,v 1.1 1998/10/14 21:09:15 cvsadmin Exp $
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.


# java::lock --
#
# 	Make a copy of the TclObject and store it in 
#	java::objLockedList.  This will increment the
#	ref-count of the ReflectObject, preventing 
#	garbage collection.
#
# Arguments:
#	args:	The Tcl variable that is currently 
#		pointing to a Java object. 	
#
# Results:
# 	If javaObject does not reference a valid javaObject
#	an error is generated by the call to java::isnull.

proc java::lock {args} {
    global java::objLockedList

    # Make a copy of the object.

    set copy [format %s $args]
    
    # Test the number of arguments.
    
    if {[llength $copy] != 1} {
	error "wrong # args: should be \"java::lock object\""
    }

    # Store the object internally.

    java::isnull $copy
    lappend java::objLockedList $copy
    return $copy
}

# java::unlock --
#
#  	Remove the reference to the Java object from the
#	java::objLockedList.  This will decrement the 
#	ref-count by one.  It ref-count equals zero the 
#	Java object will be garbage collected.
#
# Arguments:
#	args:	The Tcl variable that was previously 
#		locked by a call to java::locked.
#
# Results:
# 	An error is generated if the java::objLockedList
# 	does not contain a javaObject.

proc java::unlock {args} {
    global java::objLockedList

    # Test the number of arguments.

    if {[llength $args] != 1} {
	error "wrong # args: should be \"java::unlock object\""
    }
    
    # Remove the copy of the pointer.

    set index [lsearch $java::objLockedList $args]
    if {$index < 0} {
	error "unknown java object \"$args\""
    } else {
	set java::objLockedList [lreplace $java::objLockedList $index $index]
    }
}

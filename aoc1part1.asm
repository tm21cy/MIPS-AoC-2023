#################################
#	Day 1.1 - AoC 2023	#
#	Tyler McDonald		#
#################################

# Variables (likely ignores convention, cope)
# $s0 - stores the file buffer, which in turn is our data pointer
# $s2 & $s3 - values 1 and 2 - value 1 is 10x what is represented so they can be mashed together
# $s6 - global total counter
# $s7 - local total counter
# $t0 - clobbered outside the loop, but is used as byte storage in the findCharacters loop
# $t1 - used briefly to check for remaining valid characters

.data
file: 		.asciiz "C:\\Users\\tm21c\\Downloads\\input.txt" # the input file path - alter at your own risk
stringnum:	.ascii "String # " # quick lil formatter string
newline:	.asciiz "\n" # does what it says on the tin
buffer:		.space 24576 # size of the provided input on disk
chars:		.word 21808 # calculated characters in file

.text
# entry point, basically just reads the file and preps the buffer
main:
	jal	readFile
	la	$s0, buffer
	
# while there are still valid runs of characters, read, total, and output
loop:
	jal	findCharacters
	
	li	$t0, 10 # for doing (10x1)+2, to simulate 1+2=12
	mul	$s2, $s2, $t0 # see above
	add	$s7, $s2, $s3 # increment local total
	add	$s6, $s6, $s7 # increment global total
	jal	printResult
	
	# reset local values
	li	$s2, 0
	li	$s3, 0
	
	# check for remaining valid characters
	lb	$t1, -1($s0)
	bnez	$t1, loop

	# end otherwise
	b	end

# reads an input file first to a descriptor, then to a buffer
readFile:
	# 13 is open file op, returns a file descriptor
	li	$v0, 13
	la	$a0, file
	syscall
	
	# store file descriptor
	move	$a0, $v0
	
	# 14 is read file op, returns num of chars read (unused)
	li	$v0, 14
	la	$a1, buffer
	la	$a2, chars
	syscall
	
	jr	$ra

# finds valid characters by iterating through the buffer
findCharacters:
	# unclobber prior data
	li	$t0, 0
	
	# load next byte and increment
	lbu	$t0, ($s0)
	addi	$s0, $s0, 1
	
	# if byte is \0, CR or LF, break
	beq	$t0, 0, charBreak
	beq	$t0, 10, charBreak
	beq	$t0, 13, charBreak
	
	# if byte is outside ASCII integer range, loop
	blt	$t0, 48, findCharacters
	bgt	$t0, 57, findCharacters
	
	# if we have no first occurrence, make this the first occurrence
	beqz	$s2, charUp1
	
	# otherwise set/reset last occurrence.
	b	charUp2 
	
	
charUp1:
	# mask to extract integer
	andi	$s2, $t0, 0x0F
	b	findCharacters

charUp2:
	# mask to extract integer
	andi	$s3, $t0, 0x0F
	b	findCharacters
	
charBreak:
	# if only one integer appeared, duplicate its occurrence
	beqz	$s3, duplicate
	jr	$ra

duplicate:
	# copy first occurrence into last occurrence
	move	$s3, $s2
	jr	$ra

printResult:
	# print integer, then newline (1 is print int, 4 is print str)
	li	$v0, 1
	move	$a0, $s7
	syscall
	
	li	$v0, 4
	la	$a0, newline
	syscall
	
	jr	$ra
	
end:
	# print double newline, then final total
	li	$v0, 4
	la	$a0, newline
	syscall
	li	$v0, 4
	la	$a0, newline
	syscall
	
	li	$v0, 1
	move	$a0, $s6
	syscall
	
	# sys exit
	li	$v0, 10
	syscall

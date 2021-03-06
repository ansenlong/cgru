from parsers import parser

import re

re_frame = re.compile(r'PROGRESS: .* (.*): .* Seconds')

class afterfx(parser.parser):
	'Adobe After Effects'
	def __init__( self):
		parser.parser.__init__( self)
		self.firstframe = True

	def do( self, data, mode):
		match = re_frame.search( data)
		if match is None: return      
		if not self.firstframe: self.frame += 1
		self.firstframe = False
		self.calculate()

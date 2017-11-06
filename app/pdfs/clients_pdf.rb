class ClientsPdf < Prawn::Document

	def initialize(clients, params)
		super(top_margin: 10, :page_layout => :landscape, margin: [0, 15, 0, 15])
		@cliente = clients
		@grupo = params
		grupo_rows
		cabecera_rows
		line_items
	end

	#NUMERO DE GRUPO
		def grupo_rows
			data = [["\ #{@grupo}"]]
				table data, :cell_style => { :width => 760, :height => 590, :size => 200, :align => :center, :padding_top => 230, :color => '2ECCFA'}
		end
	#FIN NUMERO DE grupo

	#CABECERA

		def cabecera_rows
			data = [["\nGRUPO: \ #{@grupo}" "\nNombre y Firma de Capturista:________________"] + [:image => "#{Rails.root}/app/assets/images/ccs.png",  :position => :center]]
			table data, :cell_style => { :width => 381, :background_color => 'CEF6F5'}
		end
	#CABECERA

#LISTA CLIENTES
	def line_items
		table clients_rows, :cell_style => {:padding => 3, :size => 9}
	end

	def clients_rows

	  rows = []
	  rows << ['NOMBRE','DIRECCIÓN', 'NOMBRE AVAL', 'DIRECCION AVAL', 'GARANTIAS', 'MONTO', 'P  1', 'P  2', 'P  3', 'P  4', 'P  5', 'P  6', 'P  7', 'P  8', 'P  9', 'P 10', 'P 11', 'P 12', 'P 13', 'P 14', 'P 15' ]

	  @cliente.each do |clt|
	    @cliente_row = clt.nombre + ' ' + clt.apellidos
			@dir_row = clt.direccion
			@monto = clt.monto
	     clt.avals.map do |avl|
	      @aval_row = avl.nombre + ' ' + avl.apellidos
				@dir_row = avl.direccion
				clt.warranties.map do |gar|
					@gar_row = gar.garantia1 + ',' + gar.garantia2 + ',' + gar.garantia3 + ',' + gar.garantia4
		 end
	 end
	    rows << [@cliente_row,@dir_row, @aval_row, @dir_row, @gar_row, @monto, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
	  end
	  rows
	end
#FIN LISTA CLIENTES

end

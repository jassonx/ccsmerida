class ClientsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_jefecaptura!, only: [:edit, :update]
  before_action :authenticate_admin!, only: [:destroy]


  def renovar
    @client = Client.find(params[:id])
    respond_to do |format|
      if @client.update(monto: params[:term].to_i, visita: params[:date], status:"Activo", grupo: params[:grup].to_i)
         @registro = Record.new(registro: @client.payment.registro, client_id: @client.id)
         @registro.save!
         @client.payment.update(num_pago: 1, monto: @client.calcula_pago_total, multa:0, registro:"")
        format.html { redirect_to clients_path, notice: 'Se renovó un cliente.' }
        format.json { redirect_to clients_path, status: :ok, location: @client }
        format.js
      else
        format.html { render clients_path }
        format.json { render json: @client.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # GET /clients
  # GET /clients.json
  def index
    @search = Client.search(params[:q])
    @clients = @search.result
    @warranties = Warranty.all
    @avals = Aval.all
    @total = 0


   @clients.each {|elemento|
    if elemento.status == "Activo"
      @total = @total+elemento.calcula_pago_total
    end}

  #actualiza pagos
   @date = Date.today.strftime("%A")

   if @date == "Sunday"

       @clients.each do |client|
          if  client.payment.updated_at.today?
             #client.actualiza_pagos
             flash.now[:notice] = 'Todos los registros han sido actualizados!'
          else
              #flash.now[:notice] = 'Todos los registros han sido actualizados!'
              client.actualiza_pagos
          end
      end
    end
   #fin actualiza pagos

   #Generar PDf
  if  params[:ruta].present? && params[:grupo].present? && params[:localidad].present?
    @grupos = params[:grupo]
   @filtro = Client.where("ruta = ? AND grupo = ? AND localidad like ?", params[:ruta], params[:grupo], params[:localidad])
     pdf = ClientsPdf.new(@filtro, @grupos)

     send_data pdf.render, filename: 'clients.pdf', type: 'application/pdf', disposition: 'inline'
  end
  #fin pdf
  end


  # GET /clients/1
  # GET /clients/1.json
  def show
    if @client.status == "Activo"
      @warranty = @client.warranties
      @aval = @client.avals
      @dia_visita = @client.nombre_dia_semana
      @fecha = @client.suma_dias
      @dia_pago = @fecha.strftime("%A")
      @pago_con_interes = @client.calcula_pago_total
      @pago_por_semana = @client.divide_pagos
      @payment = @client.payment
    else
      redirect_to clients_path
    end

  end

  # GET /clients/new
  def new
    @client = Client.new
    @warranties = @client.warranties.build
    @avals = @client.avals.build
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    logger.info @client.valid?.inspect
    logger.info @client.errors.full_messages.inspect
    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Se agregó un cliente.'}
        format.json { render :show, status: :created, location: @client }
      else
        @avals = @client.avals.build
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update

    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to clients_path, notice: 'Se modificó un cliente.' }
        format.json { respond_with_bip(@client)  }
        format.js
      else
        format.html { render :edit }
        format.json { respond_with_bip(@client)  }
        format.js
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Se eliminó un cliente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:status, :nombre, :apellidos, :tipo, :localidad, :direccion, :celular, :ine, :ruta, :grupo, :monto, :visita,
       warranties_attributes: [:id, :garantia1, :garantia2, :garantia3, :garantia4],
       avals_attributes: [:id, :nombre, :apellidos, :ine, :direccion, :celular])
    end

    def set_monto
      params.require(:client).permit(:monto)
    end
end

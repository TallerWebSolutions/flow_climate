# frozen_string_literal: true

class ProductsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_product, only: %i[edit update]

  def index
    @products = @company.products.order(:name)
  end

  def new
    @product = Product.new
  end

  def edit; end

  def update
    assign_customer
    @product.update(product_params.merge(customer: @customer))
    return redirect_to company_products_path(@company) if @product.save
    render :edit
  end

  def create
    customer = Customer.find_by(id: product_params[:customer_id])
    @product = Product.new(product_params.merge(customer: customer))
    return redirect_to company_products_path(@company) if @product.save
    render :new
  end

  private

  def product_params
    params.require(:product).permit(:customer_id, :name)
  end

  def assign_product
    @product = Product.find(params[:id])
  end

  def assign_customer
    @customer = Customer.find_by(id: product_params[:customer_id])
  end
end

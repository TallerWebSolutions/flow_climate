# frozen_string_literal: true

class ProductsController < AuthenticatedController
  before_action :assign_company

  def index
    @products = @company.products.order(:name)
  end

  def new
    @product = Product.new
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
end

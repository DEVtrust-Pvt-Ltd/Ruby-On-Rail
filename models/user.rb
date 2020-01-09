class User < ActiveRecord::Base
  acts_as_paranoid
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :default_medication_lists, :dependent => :destroy
  has_many :equipments, :dependent => :destroy
  has_many :user_equipment_lists, :dependent => :destroy
  has_many :zone_defibrillation_cardioversion_doses, :dependent => :destroy
  has_one :defibrillation_and_cardioversion_formula, :dependent => :destroy

  has_one :defibrillation
  has_one :cardioversion

  has_many :shipping_addresses, :dependent => :destroy

  validates :password, format: { with: /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/ , message: "must include at least one lowercase letter, one uppercase letter, and one digit" } , :allow_blank => true, :on => :update
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  before_create :update_name
  after_create :create_med_list

  def self.search(search) name
  where("email LIKE :query OR name LIKE :query OR company LIKE :query OR phone LIKE :query", query: "%#{search}%")
  end

  def active_for_authentication?
    super and self.is_active
  end

  def inactive_message
    "You account is suspended."
  end

  def update_name
    name = "#{self.first_name}" + " #{self.last_name}"
    self.name =  name
  end
  #validates :company, presence: true, uniqueness: true

  # Rails.application.routes.draw do
  #   User.all.each do |user|
  #     get "/#{user.company}", :to => "admin_medication_list#preview_page", defaults: { id: user.id }
  #   end
  # end

  def create_med_list
    master_list = MasterList.find([5, 6, 8, 9, 10, 31, 43, 1, 4, 12, 14, 16, 18, 19, 21, 23, 24, 28, 33, 36, 37, 39, 41])

    master_list.each_with_index do |med, index|
      if index <= 19
        DefaultMedicationList.create(master_list_id: med.id, med_side: 'a', user_id: self.id, medication_name: med.name, medication_weight_based_dosage: med.weight_based_dosage, medication_concentration: med.concentration, medication_maximum_dosage: med.maximum_dosage, medication_routes: med.routes )
      else
        DefaultMedicationList.create(master_list_id: med.id, med_side: 'b',user_id: self.id, medication_name: med.name, medication_weight_based_dosage: med.weight_based_dosage, medication_concentration: med.concentration, medication_maximum_dosage: med.maximum_dosage, medication_routes: med.routes )
      end
    end

    for i in(1..15)
      DefaultMedicationList.create(med_side: 'b', user_id: self.id)
    end
  end

end

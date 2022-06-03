# создаются хосты master,node1 и node2
# провайдер - virtualbox
Vagrant.configure("2") do |config|      # настройки общие для всех VM
  config.vm.box = "ubuntu/focal64"      # образ системы используемый в VM
  config.vm.box_check_update = false    # проверка новых версий  образа
  config.vm.disk :disk, size: "10GB", primary: true # размер HDD
  config.vm.provision :file, source: './.apikey.env', destination: '~/.apikey.env' # копируем файлы внутрь vm
  config.vm.provision "shell", inline: <<-SHELL # скрипт выполняемый после загрузки всех  систем
    apt-get update -y
    echo "192.168.56.10 master" >> /etc/hosts
    echo "192.168.56.11 node1" >> /etc/hosts
    echo "192.168.56.12 node2" >> /etc/hosts
  SHELL

  config.vm.define "master" do |master|   #настраиваем VM master
    master.vm.hostname = "master"      # hostname вирутальной машины
    master.vm.network "private_network", ip: "192.168.56.10" # сетевые параметры
#    master.vm.provision "shell", path : "scripts/master.sh" # внешний скрипт,
#    выполнняемый после запуска master
    master.vm.provider "virtualbox" do |vb| # настройки для конкретного провайдера
      vb.name = "master"
      vb.memory = 2048  # ОЗУ - 2Гб
      vb.cpus = 2       # ЦП - 2 ядра
      vb.customize ["modifyvm", :id, "--audio", "none"] #аудио не нужно
      vb.check_guest_additions = false # пропускать проверку guest extensions
    end
  end

  (1..2).each do |i|  # настройка нескольких узлов в цикле от 1 до 2
    config.vm.define "node#{i}" do |node| # определяем общие настройки для nodes
      node.vm.hostname = "node#{i}" #hostname
      node.vm.network "private_network", ip: "192.168.56.1#{i}" # ip-address
#     node.vm.provision "shell", path : "scripts/node.sh" # внешний скрипт,
      node.vm.provider "virtualbox" do |vb| # "железо" для нодов
        vb.name = "node#{i}"
        vb.memory = 1024
        vb.cpus = 1
      end
    end
  end
end


# hosts = {
#  "host0" => "192.168.33.10",
#  "host1" => "192.168.33.11",
#  "host2" => "192.168.33.12"
#}
#
#hosts.each do |name, ip|
#    config.vm.define name do |machine|
#      machine.vm.box = "ubuntu/bionic64"
#      machine.vm.hostname = "%s" % name
#      machine.vm.network :private_network, ip: ip

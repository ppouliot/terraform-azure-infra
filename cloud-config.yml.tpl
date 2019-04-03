#cloud-config

coreos:
  update:
    reboot-strategy: "reboot"
    server: "https://public.update.flatcar-linux.net/v1/update/"
    group: "alpha"
  units:
    - name: "docker-tcp.socket"
      command: "start"
      content: |
        [Unit]
        Description=Docker Socket for the API
        [Socket]
        ListenStream=2375
        Service=docker.service
        BindIPv6Only=both
        [Install]
        WantedBy=sockets.target

    - name: "no-password-sudo-core.service"
      command: "start"
      content: |
        [Unit]
        Description=Configure core user for passwordless sudo
        [Service]
        Type=oneshot
        ExecStart=/bin/bash -ex /tmp/core-no-passwd-sudo.sh
        [Install]
        WantedBy=multi-user.target

    - name: "install-docker-compose.service"
      command: "start"
      content: |
        [Unit]
        Description=Install Docker Compose
        [Service]
        Type=oneshot
        ExecStart=/bin/bash -ex /tmp/install-docker-compose.sh
        [Install]
        WantedBy=multi-user.target

    - name: "install-pypy.service"
      command: "start"
      content: |
        [Unit]
        Description=Install PyPy Binaries to /home/core/pypy
        [Service]
        Type=oneshot
        ExecStart=/bin/bash -ex /tmp/install-pypy.sh
        [Install]
        WantedBy=multi-user.target

#    - name: "flatcar-linux-upgrade.service"
#      command: "start"
#      content: |
#        [Unit]
#        Description=Upgrade CoreOS to Flatcar-Linuxo /home/core/flatcar-linux-upgrade.sh
#        [Service]
#        Type=oneshot
#        ExecStart=/bin/bash -ex /home/core/flatcar-linux-upgrade.sh
#        [Install]
#        WantedBy=multi-user.target


ssh_authorized_keys:
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlZLcFVYcMbYkJ+pwSsTnfOfwmOLZe26J6PBHa/17ZuzBI563BWJfTybjgphVOJwQKAqN+cBfzHZ66PaQm0vqx2Efee1uGq/vd8cmAIyEqmZUnbkxPRQ3G7YLlAwqZalRo2TEglWhEK+O+7hycV3NhCKYpG/2DZwGbW97bKh01R3R0pt9PiSi570w4W4oeUxPioqR/dIJf+g4EnOCnPMvLAT6exGI9hcKCRH3604Qnh2z5rQ0aG4PYS8uCi5MS8AevuWxNg7OKE6e59XxDvruULq+4jerAls+HZVomZ2AQvbcabpqKFEKvVtE12k5uzAWelmZU49NCIHuUgrX5hm0X peter@hackintosh.local"
  - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKetw3EOkjAc3+QuDbumo1GovGzCZbQ7McDDFPyis779 peter@quartermaster"
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq1k6++HIrouWWMw/TevD4SaPcMoOHl5rNqGNZ5FghSJb8F7A7DiDhnU8MW8x5pClrQQyY6KTKUI7p1PZptuiNbhf7c2T0O+Rxf0PB0Pt8qZ5RK65rJOXBhPaYt7VBMM18fOrdojoj4kchdRfEYRny4xy3uj3qNwzUSdxRYWDi/q6IGl5wJjVN6O/cvSz/V6hVTi+Hcm+Luch1ZiWlXefuUbIwvBvgazCBx7fPeh4l1DBFtzAec3MUKY73PTcuHfvv/6Nwy4NtRRZAA45Mk6aGDoo1lMeJZUoyKw7ev6XRt9g30s7uqDNDXaieOJlhDCXdOo5cC9Sc4flLFtjk/UsZqjxNl5UALxIw4ZrZ1A/byKZ5gXQ3b6vTR17eu5dhZTClnGIgZZ3R4DNuaNUozlJwoviC8MHe8NIu6H6VseN70MMQX/xdYqDWM45AYo00N3kslndVvoWVGbVlc+0qSisKkJ1Q1ceMmPmsJBvUlcvI5WYFu0wncj1J2sV5uQIzzlGDb/WjthCXN8I+NS29xMi6hDewYrP9Z8+nrDHPpuMCEeQb6tT8fZbytVNRrravetzdqnFFX7qpIkY7UjfHVeDG53l2yknyJJOGr2QPuDwaQvEHmdlb1O2MHTOMFHnNhDQs3Tj8Nvl0BNZmB2N8RcyFny6x3C2+9VhkXAzvn+kitQ== hyper-v_ci@microsoft.com"

users:
  - name: "core"
#   password_hash: coreos
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlZLcFVYcMbYkJ+pwSsTnfOfwmOLZe26J6PBHa/17ZuzBI563BWJfTybjgphVOJwQKAqN+cBfzHZ66PaQm0vqx2Efee1uGq/vd8cmAIyEqmZUnbkxPRQ3G7YLlAwqZalRo2TEglWhEK+O+7hycV3NhCKYpG/2DZwGbW97bKh01R3R0pt9PiSi570w4W4oeUxPioqR/dIJf+g4EnOCnPMvLAT6exGI9hcKCRH3604Qnh2z5rQ0aG4PYS8uCi5MS8AevuWxNg7OKE6e59XxDvruULq+4jerAls+HZVomZ2AQvbcabpqKFEKvVtE12k5uzAWelmZU49NCIHuUgrX5hm0X peter@hackintosh.local"
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKetw3EOkjAc3+QuDbumo1GovGzCZbQ7McDDFPyis779 peter@quartermaster"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBphxofd/o0IuSXu+e6BfIBYid20Xshd7eia4RaEXyMVq5IKLo8OdYMQAZiGHmf+cKMSIZTGk0sFR/cPDYNwpfIzamnvXYxUXR9m8a/YHkNfSDMcJFl8nXusqCrP1NGfonUAGa6bpNYLy6CJ/Zy/mDyqYzUwWvyRBEGqlfovvjAjDgV3Yw2gL5f3cgyaZw7/fOlFKx6jFo6xWR6iQxFwoaHuNXYp7pK6YhWHfRym/2GF6aau78lnf24blzJjK3kVOCTOyihFTYWAP54vlibJs1SwVauH1r0lmmQtX+oau6foXamc7oasGJxZtUNlBFJHttkGkri5y8x7wObDv/oYT60NwwNXBQhl23JgpDFKt2KUUhv8psU0G8VlWv84KdnuatfZSTve+vBiAhp+KR/mgBAMwPpSny2dxOpVpkwJk9d727l4dtXKkKJfkf3q9Diy2350PLUETdW9f6Q6Yn2sGcOYXgTgGkJlkJTIu5Af3ETjpaNteZioYigcuqv0slnQXCDALGDOgz0LhQBwBMqsd1WHM9OgFK9NcQR2q9I3+n/fqilButJVRnSukO4SXUd1aL4u83rOBjyGTBoQyxGE1hBFUTQaS6AxugXKV3jJ8UfD9+/WT1yrCkimKqFhh/8jTRInzKgwgJ0STH6wruUIkhj/5Bipm8fwBgTMHFpYpv9Q== ansible"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/zjq9YmfaLIGCC3B6j/CMsQbK4GQ6lWwjenwC8+OyuzQwXG1TOGpV0T0E8O0jro/sUJ5TPxvKwxgjxMlcasSsgNLkVJSXYBgH+fttpPOR7Gt8vGqeQ8FlGczmOb20fRKT3cv41/+tJTB+NRUL5jgzocjNKJ7N/p5bxOZ9/TDE8tE3KiYgauEV2FZEyZ4peAdf8viTYo7fOAj9csKDQsCCJc4d/H4B8rcOnADoa/opUw5v0/jxYKWq5oZEueQQE7cJputIppgqAwoE5/Eb6Ufu1Ra5J+IFbmWAEKGOrN3jZFFK3EfuROkK40yI1VwL/VJkIXzsp4Ec8Yu6ath+kUPGW9QD4UNLS7MGGW8xAVKtGwfj0KkSSmJhI7TOlkXAFuctiSk97GZGrwX70HGXpaJb0mMNmCTsO+yZEMM/YU9IEW7ekNwnLNfN5VMKnEQxv5eGwEkOl/k/ThVAzJO/2vHSQDDIfLKL3Vf2AuyR1uAxkAfwd9LW0uEJUZSAWBfbg/2qQd8wqWfhw8kSNyKaMIn0nMCqo39+o3nz+mhB4gHrbXUBSi25hiwr1yLBJg8cEscYDRaoWVjaUnJiz0v/6mjjP0VROdgJm980Zn0X8kgHUg1OzKH9QoRYA5eiRNsEPsxvdBUQqb37qsrdcQ9/h1bKgaopnwpgNe/OA/VO/4lzkU= jenkins@jenkins"


  - name: "jenkins"
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBphxofd/o0IuSXu+e6BfIBYid20Xshd7eia4RaEXyMVq5IKLo8OdYMQAZiGHmf+cKMSIZTGk0sFR/cPDYNwpfIzamnvXYxUXR9m8a/YHkNfSDMcJFl8nXusqCrP1NGfonUAGa6bpNYLy6CJ/Zy/mDyqYzUwWvyRBEGqlfovvjAjDgV3Yw2gL5f3cgyaZw7/fOlFKx6jFo6xWR6iQxFwoaHuNXYp7pK6YhWHfRym/2GF6aau78lnf24blzJjK3kVOCTOyihFTYWAP54vlibJs1SwVauH1r0lmmQtX+oau6foXamc7oasGJxZtUNlBFJHttkGkri5y8x7wObDv/oYT60NwwNXBQhl23JgpDFKt2KUUhv8psU0G8VlWv84KdnuatfZSTve+vBiAhp+KR/mgBAMwPpSny2dxOpVpkwJk9d727l4dtXKkKJfkf3q9Diy2350PLUETdW9f6Q6Yn2sGcOYXgTgGkJlkJTIu5Af3ETjpaNteZioYigcuqv0slnQXCDALGDOgz0LhQBwBMqsd1WHM9OgFK9NcQR2q9I3+n/fqilButJVRnSukO4SXUd1aL4u83rOBjyGTBoQyxGE1hBFUTQaS6AxugXKV3jJ8UfD9+/WT1yrCkimKqFhh/8jTRInzKgwgJ0STH6wruUIkhj/5Bipm8fwBgTMHFpYpv9Q== ansible"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/zjq9YmfaLIGCC3B6j/CMsQbK4GQ6lWwjenwC8+OyuzQwXG1TOGpV0T0E8O0jro/sUJ5TPxvKwxgjxMlcasSsgNLkVJSXYBgH+fttpPOR7Gt8vGqeQ8FlGczmOb20fRKT3cv41/+tJTB+NRUL5jgzocjNKJ7N/p5bxOZ9/TDE8tE3KiYgauEV2FZEyZ4peAdf8viTYo7fOAj9csKDQsCCJc4d/H4B8rcOnADoa/opUw5v0/jxYKWq5oZEueQQE7cJputIppgqAwoE5/Eb6Ufu1Ra5J+IFbmWAEKGOrN3jZFFK3EfuROkK40yI1VwL/VJkIXzsp4Ec8Yu6ath+kUPGW9QD4UNLS7MGGW8xAVKtGwfj0KkSSmJhI7TOlkXAFuctiSk97GZGrwX70HGXpaJb0mMNmCTsO+yZEMM/YU9IEW7ekNwnLNfN5VMKnEQxv5eGwEkOl/k/ThVAzJO/2vHSQDDIfLKL3Vf2AuyR1uAxkAfwd9LW0uEJUZSAWBfbg/2qQd8wqWfhw8kSNyKaMIn0nMCqo39+o3nz+mhB4gHrbXUBSi25hiwr1yLBJg8cEscYDRaoWVjaUnJiz0v/6mjjP0VROdgJm980Zn0X8kgHUg1OzKH9QoRYA5eiRNsEPsxvdBUQqb37qsrdcQ9/h1bKgaopnwpgNe/OA/VO/4lzkU= jenkins@jenkins"


    groups:
      - docker

  - name: "git"
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBphxofd/o0IuSXu+e6BfIBYid20Xshd7eia4RaEXyMVq5IKLo8OdYMQAZiGHmf+cKMSIZTGk0sFR/cPDYNwpfIzamnvXYxUXR9m8a/YHkNfSDMcJFl8nXusqCrP1NGfonUAGa6bpNYLy6CJ/Zy/mDyqYzUwWvyRBEGqlfovvjAjDgV3Yw2gL5f3cgyaZw7/fOlFKx6jFo6xWR6iQxFwoaHuNXYp7pK6YhWHfRym/2GF6aau78lnf24blzJjK3kVOCTOyihFTYWAP54vlibJs1SwVauH1r0lmmQtX+oau6foXamc7oasGJxZtUNlBFJHttkGkri5y8x7wObDv/oYT60NwwNXBQhl23JgpDFKt2KUUhv8psU0G8VlWv84KdnuatfZSTve+vBiAhp+KR/mgBAMwPpSny2dxOpVpkwJk9d727l4dtXKkKJfkf3q9Diy2350PLUETdW9f6Q6Yn2sGcOYXgTgGkJlkJTIu5Af3ETjpaNteZioYigcuqv0slnQXCDALGDOgz0LhQBwBMqsd1WHM9OgFK9NcQR2q9I3+n/fqilButJVRnSukO4SXUd1aL4u83rOBjyGTBoQyxGE1hBFUTQaS6AxugXKV3jJ8UfD9+/WT1yrCkimKqFhh/8jTRInzKgwgJ0STH6wruUIkhj/5Bipm8fwBgTMHFpYpv9Q== ansible"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB/zjq9YmfaLIGCC3B6j/CMsQbK4GQ6lWwjenwC8+OyuzQwXG1TOGpV0T0E8O0jro/sUJ5TPxvKwxgjxMlcasSsgNLkVJSXYBgH+fttpPOR7Gt8vGqeQ8FlGczmOb20fRKT3cv41/+tJTB+NRUL5jgzocjNKJ7N/p5bxOZ9/TDE8tE3KiYgauEV2FZEyZ4peAdf8viTYo7fOAj9csKDQsCCJc4d/H4B8rcOnADoa/opUw5v0/jxYKWq5oZEueQQE7cJputIppgqAwoE5/Eb6Ufu1Ra5J+IFbmWAEKGOrN3jZFFK3EfuROkK40yI1VwL/VJkIXzsp4Ec8Yu6ath+kUPGW9QD4UNLS7MGGW8xAVKtGwfj0KkSSmJhI7TOlkXAFuctiSk97GZGrwX70HGXpaJb0mMNmCTsO+yZEMM/YU9IEW7ekNwnLNfN5VMKnEQxv5eGwEkOl/k/ThVAzJO/2vHSQDDIfLKL3Vf2AuyR1uAxkAfwd9LW0uEJUZSAWBfbg/2qQd8wqWfhw8kSNyKaMIn0nMCqo39+o3nz+mhB4gHrbXUBSi25hiwr1yLBJg8cEscYDRaoWVjaUnJiz0v/6mjjP0VROdgJm980Zn0X8kgHUg1OzKH9QoRYA5eiRNsEPsxvdBUQqb37qsrdcQ9/h1bKgaopnwpgNe/OA/VO/4lzkU= jenkins@jenkins"


write_files:
  - path: "/etc/motd"
    permissions: "0644"
    owner: "root"
    content: |
      Automically provisioned from terraform

  - path: "/tmp/core-no-passwd-sudo.sh"
    permissions: "0777"
    owner: "core"
    content: |
      #!/usr/bin/env bash
      LOGFILE='/home/core/core-no-passwd-sudo.log'
      exec >> $LOGFILE 2>&1
      echo "Setting passwordless sudo for core user"
      sed -i "/core/c\core\ ALL\=\(ALL\)\ NOPASSWD\:\ ALL" /etc/sudoers.d/waagent

  - path: "/tmp/install-docker-compose.sh"
    permissions: "0777"
    owner: "core"
    content: |
      #!/usr/bin/env bash
      HOME='/home/core'
      LOGFILE='/home/core/install-docker-compose.log'
      exec >> $LOGFILE 2>&1
      if [ ! -d $HOME/bin ];
      then 
        mkdir -p $HOME/bin
      fi
      curl -o $HOME/bin/docker-compose -L `curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[].browser_download_url | select(contains("Linux") and contains("x86_64"))'`
      chmod ugo+x $HOME/bin/docker-compose
      $HOME/bin/docker-compose --version

  - path: "/tmp/install-pypy.sh"
    permissions: "0777"
    owner: "core"
    content: |
      #!/usr/bin/env bash
      set -x
      LOGFILE='/home/core/install-pypy.log'
      exec >> $LOGFILE 2>&1
      PYPY_VERSION='pypy3.5-7.0.0-linux_x86_64-portable'
      HOME='/home/core'
      cd $HOME
      echo "Sleep 30 Seconds before downloading"
      sleep 30
      echo "Downloading PYPY Portable binary: $PYPY_VERSION"
      wget -nv https://bitbucket.org/squeaky/portable-pypy/downloads/$PYPY_VERSION.tar.bz2 ;
      tar -xjf $PYPY_VERSION.tar.bz2 ;
      mv $PYPY_VERSION pypy
      rm -rf $PYPY_VERSION.tar.bz2
      chmod -R ugo+x $HOME/pypy
      cd $HOME/pypy/bin
      $HOME/pypy/bin/pypy -m ensurepip

  - path: "/home/core/flatcar-linux-upgrade.sh"
    permissions: "0777"
    owner: "core"
    content: |
      #!/usr/bin/env bash
      LOGFILE='/home/core/upgrade_flatcar.log'
      exec >> $LOGFILE 2>&1
      echo "Get the Flatcar Linux Public Update Key."
      curl -L -o /tmp/key https://raw.githubusercontent.com/flatcar-linux/coreos-overlay/flatcar-master/coreos-base/coreos-au-key/files/official-v2.pub.pem
      echo "Mountingthe Flatcar Linux Public Update Key to /usr/share/update_engine/udate-payload-key.pub.pem."
      sudo mount --bind /tmp/key /usr/share/update_engine/update-payload-key.pub.pem
      #echo "Setting the Flatcar Linux update url in /etc/coreos/update.conf"
      #echo "SERVER=https://public.update.flatcar-linux.net/v1/update/" >> /etc/coreos/update.conf
      echo "Clearing the current version number from the release file"
      sudo cp /usr/share/coreos/release /tmp
      sudo sed -i "/COREOS_RELEASE_VERSION/c\COREOS_RELEASE_VERSION\=0.0.0" /tmp/release
      sudo mount --bind /tmp/release /usr/share/coreos/release
      echo "Restarting the CoreOS Update engine."
      sudo systemctl restart update-engine
      echo "Triggering  manual update"
      sudo update_engine_client -update

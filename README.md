```
git clone https://github.com/tropicloud/np-micro.git
docker build -t np-micro np-micro
docker run -it -p 80:80 -p 443:443 np-micro
```
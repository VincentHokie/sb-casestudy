FROM safeboda_base:latest

COPY . /app
COPY server-configs/nginx/safeboda /etc/nginx/sites-available/safeboda
COPY server-configs/service/safeboda.conf /etc/init/safeboda.conf
RUN pip install -r requirements.txt
RUN ln -s /etc/nginx/sites-available/safeboda /etc/nginx/sites-enabled && \
    nginx -t && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/init/safeboda.conf /etc/init.d/safeboda && \
    chmod +x /etc/init.d/safeboda && \
    chown -R www-data.www-data /app && \
    chown www-data.www-data /etc/nginx/uwsgi_params

EXPOSE 80
CMD service nginx restart && service safeboda start

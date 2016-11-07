/*
 * HttpDataSource.cpp
 *
 *  Created on: Oct 4, 2013
 *      Author: jgordy
 */

#include "HttpDataSource.hpp"
#include <QtCore/QFile>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <iostream>

// Declare namespaces
using namespace bb::cascades;
using namespace std;

// Constructor
HttpDataSource::HttpDataSource(QObject* pParent) :
    QObject(pParent),
    m_pManager(new QNetworkAccessManager(this)),
    m_pReply(NULL),
    m_bTransactionPending(false)
{
}

// Destructor
HttpDataSource::~HttpDataSource()
{
}

// Property accessor methods
QUrl HttpDataSource::source() const
{
    return m_source;
}

// Property accessor methods
void HttpDataSource::setSource(const QUrl& source)
{
	m_source = source;
    emit sourceChanged(m_source);
}

// Property accessor methods
QUrl HttpDataSource::target() const
{
    return m_target;
}

// Property accessor methods
void HttpDataSource::setTarget(const QUrl& target)
{
	m_target = target;
    emit targetChanged(m_target);
}

// Begin loading data
void HttpDataSource::load()
{
    // Lock the mutex
    QMutexLocker lock(&m_mutex);

    // Check if we have an operation pending
    if( !m_bTransactionPending )
    {
        // Check if source is valid
        if( m_source.isValid() )
        {
            // Construct and submit the request
            QNetworkRequest request(m_source);
            m_pReply = m_pManager->get(request);
            QObject::connect(m_pReply, SIGNAL(finished()), this, SLOT(handleFinished()));

           // Set the transaction pending flag
            m_bTransactionPending = true;

            // Log debug info
            cout << "HttpDataSource::load" << endl;
        }
        else
        {
            // Log error
            cout << "HttpDataSource::load - Invalid source file" << endl;

            // Emit error signal
            emit error((int) bb::data::DataAccessErrorType::SourceNotFound, "Invalid source file " + m_source.toString());
        }
    }
    else
    {
        // Log error
        cout << "HttpDataSource::load - Transaction is already pending" << endl;

        // Emit error signal
        emit error((int) bb::data::DataAccessErrorType::ConnectionFailure, "Transaction is already pending");
    }
}

// Abort loading data
void HttpDataSource::abort()
{
    // Lock the mutex
    QMutexLocker lock(&m_mutex);

    // Check if we have an operation pending
    if( m_bTransactionPending )
    {
        // Check if a reply instance exists
        if( m_pReply )
        {
            // Unlock the mutex while we abort
            lock.unlock();

            // Abort the operation
            m_pReply->abort();

            // Log debug info
            cout << "HttpDataSource::abort" << endl;
        }
        else
        {
            // Log error
            cout << "HttpDataSource::abort - No reply exists" << endl;
        }
    }
    else
    {
        // Log error
        cout << "HttpDataSource::abort - No transaction is pending" << endl;
    }
}

// Handler for transaction completion
void HttpDataSource::handleFinished()
{
    // Lock the mutex
    QMutexLocker lock(&m_mutex);

    // Retrieve the reply and check for validity
    QNetworkReply* pReply = qobject_cast<QNetworkReply*>(sender());
    if( pReply )
    {
        // Retrieve the network and HTTP response, if present
        QNetworkReply::NetworkError networkError = pReply->error();
        QString errorString = pReply->errorString();
        int httpResponseCode = pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QString httpResponseReason(pReply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toByteArray());
        QString httpContentType = pReply->header(QNetworkRequest::ContentTypeHeader).toString();

        // Check for error
        if( networkError == QNetworkReply::NoError )
        {
            // Retrieve data and check for image content types
            QByteArray byteArray = pReply->readAll();
            if( httpContentType == "image/jpeg" || httpContentType == "image/jpg" || httpContentType == "image/png" || httpContentType == "image/gif" )
            {
            	// Emit image data
            	Image image(byteArray);
            	emit imageLoaded(image, httpContentType);
            }
            else
            {
            	// Emit generic data
            	QVariant data(byteArray);
            	emit dataLoaded(data, httpContentType);
            }

            // Check if we have a target
            if( m_target.isValid() )
            {
                // Open target output file
                QFile outputFile(m_target.path());
                if( outputFile.open(QIODevice::WriteOnly) )
                {
                    // Write
                    outputFile.write(byteArray);
                    outputFile.close();

                    // Emit the target update signal
                    emit targetUpdated();
                }
                else
                {
                    // Log error
                    cout << "HttpDataSource::handleFinished - Unable to open output file " << m_target.toString().toStdString() << endl;

                    // Emit error signal
                    emit error((int) bb::data::DataAccessErrorType::OperationFailure, "Unable to open output file");
                }
            }

            // Log debug info
            cout << "HttpDataSource::handleFinished - HTTP: " << httpResponseCode << " " << httpResponseReason.toStdString() << endl;
        }
        else
        {
            // Log error
            cout << "HttpDataSource::handleFinished - HTTP: " << httpResponseCode << " " << httpResponseReason.toStdString() << endl;
            cout << "HttpDataSource::handleFinished - Error: " << networkError << " (" << errorString.toStdString() << ")" << endl;

            // Emit error signal
            emit error((int) bb::data::DataAccessErrorType::ConnectionFailure, errorString);
        }

        // Release the reply
        pReply->deleteLater();
    }

    // Mark transaction as completed
    m_pReply = NULL;
    m_bTransactionPending = false;
}
